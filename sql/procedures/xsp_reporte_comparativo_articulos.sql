DROP PROCEDURE IF EXISTS `xsp_reporte_comparativo_articulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_reporte_comparativo_articulos`(
    pIdEmpresa int,
    pIdsArticulos json,
    pIdsProveedores json
)
BEGIN
    DECLARE pSqlMode text;
    SET pSqlMode = @@sql_mode;
    -- SET pSqlMode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_comparativo_articulos;
    CREATE TEMPORARY TABLE tmp_inf_comparativo_articulos
        SELECT      SUBSTRING_INDEX(a.Articulo, ' ', 1) CodigoUnificado,
                    JSON_OBJECT(
                        "GroupBy", "Proveedor",
                        "ReduceBy", "PrecioCosto",
                        "ReduceFn", "function ($el1 = '', $el2 = '') { return $el1 . $el2; }",
                        "Values",   JSON_ARRAYAGG(JSON_OBJECT(
                                    'Proveedor', CONCAT(p.Proveedor, ' Articulo'),
                                    'PrecioCosto', a.Articulo
                                    ))
                    ) ArticuloProveedorJsonGroupValues,
                    JSON_ARRAYAGG(CONCAT(p.Proveedor, ' Articulo')) ArticuloProveedorJsonGroupKeys,
                    JSON_OBJECT(
                        "GroupBy", "Proveedor",
                        "ReduceBy", "PrecioCosto",
                        "ReduceFn", "function ($el1 = 0, $el2 = 0) { return $el1 + $el2; }",
                        "Values",   JSON_ARRAYAGG(JSON_OBJECT(
                                    'Proveedor', CONCAT(p.Proveedor, ' Precio Neto'),
                                    'PrecioCosto', IF(a.IdProveedor = p.IdProveedor, a.PrecioCosto, 0)
                                    ))
                    ) PrecioCostoProveedorJsonGroupValues,
                    JSON_ARRAYAGG(CONCAT(p.Proveedor, ' Precio Neto')) PrecioCostoProveedorJsonGroupKeys,
                    JSON_OBJECT(
                        "GroupBy", "Proveedor",
                        "ReduceBy", "PrecioCosto",
                        "ReduceFn", "function ($el1 = 0, $el2 = 0) { return $el1 + $el2; }",
                        "Values",   JSON_ARRAYAGG(JSON_OBJECT(
                                    'Proveedor', CONCAT(p.Proveedor, ' Precio Descuento'),
                                    'PrecioCosto', IF(a.IdProveedor = p.IdProveedor, a.PrecioCosto * (1-p.Descuento/100), 0)
                                    ))
                    ) PrecioDescuentoProveedorJsonGroupValues,
                    JSON_ARRAYAGG(CONCAT(p.Proveedor, ' Precio Descuento')) PrecioDescuentoProveedorJsonGroupKeys,
                    JSON_OBJECT(
                        "GroupBy", "Proveedor",
                        "ReduceBy", "PrecioCosto",
                        "ReduceFn", "function ($el1 = 0, $el2 = 0) { return $el1 + $el2; }",
                        "Values",   JSON_ARRAYAGG(JSON_OBJECT(
                                    'Proveedor', CONCAT(p.Proveedor, ' Precio IVA'),
                                    'PrecioCosto', IF(a.IdProveedor = p.IdProveedor, a.PrecioCosto * (1-p.Descuento/100) * (1-t.Porcentaje/100), 0)
                                    ))
                    ) PrecioIVAProveedorJsonGroupValues,
                    JSON_ARRAYAGG(CONCAT(p.Proveedor, ' Precio IVA')) PrecioIVAProveedorJsonGroupKeys
        FROM        Articulos a
        INNER JOIN  Proveedores p
        INNER JOIN  TiposIVA t USING(IdTipoIVA)
        WHERE       a.IdEmpresa = pIdEmpresa AND p.IdEmpresa = pIdEmpresa
                    AND a.Estado = 'A' AND p.Estado = 'A'
                    AND (pIdsArticulos IS NULL OR JSON_CONTAINS(pIdsArticulos, CONCAT('', a.IdArticulo), '$'))
                    AND (pIdsProveedores IS NULL OR JSON_CONTAINS(pIdsProveedores, CONCAT('', p.IdProveedor), '$'))
        GROUP BY    CodigoUnificado
        -- HAVING      (pIdsArticulos IS NULL OR JSON_CONTAINS(pIdsArticulos, CONCAT('"', CONCAT('', CodigoUnificado), '"'), '$'))
        ORDER BY    1 DESC
        LIMIT       10;

    -- f_calcular_precio_articulo(a.IdArticulo, p.Descuento, 0) PrecioDescuento
    -- pPrecioCosto * (1-pDescuento/100) * (1+pPorcentajeIVA/100) * (1+pPorcentaje/100)

    -- SELECT      NULL `Código Unificado`, 
    --             JSON_OBJECT(
    --                 "GroupBy", "Proveedor",
    --                 "ReduceBy", "PrecioCosto",
    --                 "ReduceFn", "function ($el1 = 0, $el2 = 0) { return $el1 + $el2; }",
    --                 "Values",   JSON_ARRAYAGG(JSON_OBJECT(
    --                             'Proveedor', CONCAT(p.Proveedor, ' Precio Neto'),
    --                             'PrecioCosto', 0
    --                             ))
    --             ) PrecioCostoProveedorJsonGroupValues,
    --             JSON_ARRAYAGG(CONCAT(p.Proveedor, ' Precio Neto')) PrecioCostoProveedorJsonGroupKeys
    -- FROM        Proveedores p
    -- WHERE       p.IdEmpresa = pIdEmpresa AND p.Estado = 'A'
    --             AND (pIdsProveedores IS NULL OR JSON_CONTAINS(pIdsProveedores, CONCAT('', p.IdProveedor), '$'))
    -- UNION ALL
    SELECT      `CodigoUnificado` `Código Unificado`,
                ArticuloProveedorJsonGroupValues, ArticuloProveedorJsonGroupKeys,
                PrecioCostoProveedorJsonGroupValues, PrecioCostoProveedorJsonGroupKeys,
                PrecioDescuentoProveedorJsonGroupValues, PrecioDescuentoProveedorJsonGroupKeys,
                PrecioIVAProveedorJsonGroupValues, PrecioIVAProveedorJsonGroupKeys
    FROM        tmp_inf_comparativo_articulos;

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_comparativo_articulos;

    SET sql_mode= (SELECT pSqlMode);
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;