DROP PROCEDURE IF EXISTS `xsp_reporte_cantidades_vendidas`;
DELIMITER $$
CREATE PROCEDURE `xsp_reporte_cantidades_vendidas`(
    pIdEmpresa int,
    pFechaInicio date,
    pFechaFin date,
    pIdPuntoVenta int,
    pTipoVenta char(1),
    pIdsArticulosIncluidos json,
    pIdsArticulosExcluidos json,
    pIdProveedor bigint,
    pIdCliente bigint
)
BEGIN
    DECLARE pTotal, pCantidad DECIMAL(14,2);
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET pIdPuntoVenta = COALESCE(pIdPuntoVenta, 0);
    SET pIdProveedor = COALESCE(pIdProveedor, 0);
    SET pIdCliente = COALESCE(pIdCliente, 0);
    SET pTipoVenta = COALESCE(pTipoVenta, 'T');

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_cantidades_vendidas;
    CREATE TEMPORARY TABLE tmp_inf_cantidades_vendidas
        SELECT      v.IdVenta, v.FechaAlta 'Fecha',
                    lv.Cantidad `Cantidad`,
                    a.Articulo `Descripción`,
                    lv.Precio `$ Precio de Venta`,
                    CASE v.Tipo
                        WHEN 'V' THEN 'Venta'
                        WHEN 'P' THEN 'Presupuesto'
                        WHEN 'C' THEN 'Cotizacion'
                        ELSE 'Otro'
                    END 'Tipo de Venta',
                    IF(cl.Tipo = 'F', CONCAT(cl.Nombres, ' ', cl.Apellidos), cl.RazonSocial) Cliente,
                    -- SUM(lv.Cantidad * lv.Precio) '$ Monto Total',
                    pv.PuntoVenta 'Punto de Venta',
                    pr.Proveedor
        FROM        Ventas v
        INNER JOIN  Clientes cl USING(IdCliente)
        INNER JOIN  LineasVenta lv ON v.IdVenta = lv.IdVenta
        INNER JOIN  Articulos a USING(IdArticulo)
        INNER JOIN  Proveedores pr USING(IdProveedor)
        INNER JOIN  PuntosVenta pv ON v.IdPuntoVenta = pv.IdPuntoVenta
        WHERE       v.IdEmpresa = pIdEmpresa AND v.Estado IN ("A", "P") AND
                    (v.FechaAlta BETWEEN pFechaInicio AND CONCAT(pFechaFin, ' 23:59:59')) AND 
                    v.IdPuntoVenta = IF(pIdPuntoVenta = 0, v.IdPuntoVenta, pIdPuntoVenta)
                    AND (pTipoVenta = 'T' OR IF(pTipoVenta = 'Z', v.Tipo IN ('P', 'V'), v.Tipo = pTipoVenta))
                    AND (pIdsArticulosIncluidos IS NULL OR JSON_CONTAINS(pIdsArticulosIncluidos, CONCAT('', lv.IdArticulo), '$'))
                    AND (pIdsArticulosExcluidos IS NULL OR !(JSON_CONTAINS(pIdsArticulosExcluidos, CONCAT('', lv.IdArticulo), '$')))
                    AND (pIdProveedor = 0 OR pr.IdProveedor = pIdProveedor)
                    AND (pIdCliente = 0 OR cl.IdCliente = pIdCliente)
        ORDER BY    v.IdVenta DESC;


    SELECT  SUM(`$ Precio de Venta`), SUM(`Cantidad`)
    INTO    pTotal, pCantidad
    FROM    tmp_inf_cantidades_vendidas;

    SELECT      CONCAT(pFechaFin, ' 23:59:59') Fecha, pCantidad `Cantidad`, 'Acumulado' `Descripción`,
                '-' `Tipo de Venta`, '-' `Cliente`, '-' `Punto de Venta`, '-' `Proveedor`
    UNION ALL
    SELECT      `Fecha`,  `Cantidad`, `Descripción`,
                `Tipo de Venta`, `Cliente`, `Punto de Venta`, `Proveedor`
    FROM        tmp_inf_cantidades_vendidas
    ORDER BY    Fecha DESC;


    DROP TEMPORARY TABLE IF EXISTS tmp_inf_cantidades_vendidas;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;