DROP PROCEDURE IF EXISTS `xsp_reporte_renta_bruta`;
DELIMITER $$
CREATE PROCEDURE `xsp_reporte_renta_bruta`(
    pIdEmpresa int,
    pFechaInicio date,
    pFechaFin date,
    pIdsArticulos json,
    pIdsProveedores json
)
BEGIN
    DECLARE pCompra, pVenta DECIMAL(14,2);
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_renta_bruta;
    CREATE TEMPORARY TABLE tmp_inf_renta_bruta
        SELECT      v.IdVenta,
                    v.FechaAlta 'Fecha',
                    a.IdArticulo, a.Articulo,
                    p.Proveedor,
                    COALESCE(lv.Cantidad, 0) `Cantidad`,
                    COALESCE(lv.Cantidad * f_calcular_precio_articulo(a.IdArticulo, p.Descuento, 0), 0) `$ Monto Compra`,
                    COALESCE(lv.Cantidad * lv.Precio, 0) `$ Monto Venta`
        FROM        Ventas v
        INNER JOIN  LineasVenta lv ON v.IdVenta = lv.IdVenta
        INNER JOIN  Articulos a USING(IdArticulo)
        INNER JOIN  Proveedores p USING(IdProveedor)
        WHERE       v.IdEmpresa = pIdEmpresa AND v.Estado IN ("A", "P")
                    AND (v.FechaAlta BETWEEN pFechaInicio AND CONCAT(pFechaFin, ' 23:59:59'))
                    AND (pIdsArticulos IS NULL OR JSON_CONTAINS(pIdsArticulos, CONCAT('', lv.IdArticulo), '$'))
                    AND (pIdsProveedores IS NULL OR JSON_CONTAINS(pIdsProveedores, CONCAT('', p.IdProveedor), '$'))
        -- GROUP BY    v.IdVenta
        ORDER BY    v.IdVenta DESC;

    SELECT  SUM(`$ Monto Compra`), SUM(`$ Monto Venta`)
    INTO    pCompra, pVenta
    FROM    tmp_inf_renta_bruta;

    SELECT      CONCAT(pFechaFin, ' 23:59:59') Fecha,
                '-' `Proveedor`, '-' `Artículo`, '-' `Cantidad`,
                pCompra `$ Monto Compra`,
                pVenta `$ Monto Venta`,
                pVenta - pCompra `$ Renta Bruta`
    UNION ALL
    SELECT      `Fecha`, `Proveedor`, 'Articulo' `Artículo`, `Cantidad`,
                `$ Monto Compra`, `$ Monto Venta`, 
                `$ Monto Venta` - `$ Monto Compra` `$ Renta Bruta`
    FROM        tmp_inf_renta_bruta
    ORDER BY    Fecha DESC;

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_renta_bruta;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;