DROP PROCEDURE IF EXISTS `xsp_reporte_ventas`;
DELIMITER $$
CREATE PROCEDURE `xsp_reporte_ventas`(
    pIdEmpresa int,
    pFechaInicio date,
    pFechaFin date,
    pIdPuntoVenta int,
    pTipoVenta char(1),
    pIdMedioPago int,
    pIdArticulo bigint,
    pIdProveedor bigint,
    pIdUsuario bigint,
    pIdCliente bigint
)
BEGIN
    DECLARE pTotal, pPagado, pDeuda, pCantidadArticulos DECIMAL(14,2);
    DECLARE pVentas json;
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET pIdPuntoVenta = COALESCE(pIdPuntoVenta, 0);

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_ventas;
    CREATE TEMPORARY TABLE tmp_inf_ventas
        SELECT      v.IdVenta, v.FechaAlta 'Fecha',
                    CASE v.Tipo
                        WHEN 'V' THEN 'Venta'
                        WHEN 'P' THEN 'Presupuesto'
                        WHEN 'C' THEN 'Cotizacion'
                        ELSE 'Otro'
                    END 'Tipo de Venta',
                    SUM(lv.Cantidad) `Cantidad de Articulos`,
                    v.Monto '$ Monto Total',
                    COALESCE((SELECT SUM(p.Monto) FROM Pagos p WHERE p.Codigo = v.IdVenta AND p.Tipo = 'V'), 0) '$ Monto Pagado',
                    COALESCE((v.Monto - (SELECT SUM(p.Monto) FROM Pagos p WHERE p.Codigo = v.IdVenta AND p.Tipo = 'V')), v.Monto) '$ Deuda',
                    JSON_OBJECT(
                        "GroupBy", "MedioPago",
                        "ReduceBy", "Monto",
                        "ReduceFn", "function ($el1 = 0, $el2 = 0) { return $el1 + $el2; }",
                        "Values", (
                            SELECT 
                                JSON_ARRAYAGG(JSON_OBJECT(
                                    'MedioPago', CONCAT('$ ', mp.MedioPago),
                                    'Monto', p.Monto
                                ))

                            FROM Pagos p
                            INNER JOIN MediosPago mp USING(IdMedioPago)
                            WHERE   p.Codigo = v.IdVenta AND p.Tipo = 'V'
                        )
                    ) PagosJsonGroupValues,
                    null PagosJsonGroupKeys, -- Se agrega junto con los totales
                    GROUP_CONCAT(CONCAT(lv.Cantidad, ' x ', a.Articulo)) Articulos,
                    GROUP_CONCAT(pr.Proveedor) Proveedores, pv.PuntoVenta 'Punto de Venta',
                    CONCAT(u.Nombres, ' ', u.Apellidos) Vendedor,
                    IF(cl.Tipo = 'F', CONCAT(cl.Nombres, ' ', cl.Apellidos), cl.RazonSocial) Cliente
        FROM        Ventas v
        INNER JOIN  Clientes cl USING(IdCliente)
        INNER JOIN  LineasVenta lv ON v.IdVenta = lv.IdVenta
        INNER JOIN  Articulos a USING(IdArticulo)
        INNER JOIN  Proveedores pr USING(IdProveedor)
        INNER JOIN  PuntosVenta pv ON v.IdPuntoVenta = pv.IdPuntoVenta
        INNER JOIN  Usuarios u ON v.IdUsuario = u.IdUsuario
        WHERE       v.IdEmpresa = pIdEmpresa AND
                    (v.FechaAlta BETWEEN pFechaInicio AND CONCAT(pFechaFin, ' 23:59:59')) AND 
                    v.IdPuntoVenta = IF(pIdPuntoVenta = 0, v.IdPuntoVenta, pIdPuntoVenta)
                    AND (pTipoVenta = 'T' OR IF(pTipoVenta = 'Z', v.Tipo IN ('P', 'V'), v.Tipo = pTipoVenta))
                    AND (pIdMedioPago = 0 OR EXISTS (SELECT 1 FROM Pagos p WHERE p.Codigo = v.IdVenta AND p.Tipo = 'V' AND p.IdMedioPago = pIdMedioPago))
                    AND (pIdArticulo = 0 OR lv.IdArticulo = pIdArticulo)
                    AND (pIdProveedor = 0 OR pr.IdProveedor = pIdProveedor)
                    AND (pIdUsuario = 0 OR u.IdUsuario = pIdUsuario)
                    AND (pIdCliente = 0 OR cl.IdCliente = pIdCliente)
        GROUP BY    v.IdVenta
        ORDER BY    v.IdVenta desc;


    SELECT  SUM(`$ Monto Total`), SUM(`$ Monto Pagado`), SUM(`$ Deuda`),
            JSON_ARRAYAGG(IdVenta), SUM(`Cantidad de Articulos`)
    INTO    pTotal, pPagado, pDeuda, pVentas, pCantidadArticulos
    FROM    tmp_inf_ventas;

    SELECT  Fecha, `Tipo de Venta`, `Cantidad de Articulos`, `$ Monto Total`,
            `$ Monto Pagado`, `$ Deuda`, PagosJsonGroupValues, PagosJsonGroupKeys,
            Articulos, `Punto de Venta`, Vendedor, Cliente
    FROM    tmp_inf_ventas
    UNION ALL
    SELECT  NOW(), 'TOTALES', pCantidadArticulos, pTotal, pPagado, pDeuda,
            JSON_OBJECT(
                "GroupBy", "MedioPago",
                "ReduceBy", "Monto",
                "ReduceFn", "function ($el1 = 0, $el2 = 0) { return $el1 + $el2; }",
                "Values", (
                    SELECT
                        JSON_ARRAYAGG(JSON_OBJECT(
                            'MedioPago', CONCAT('$ ', mp.MedioPago),
                            'Monto', p.Monto
                        ))
                    FROM Pagos p
                    INNER JOIN MediosPago mp USING(IdMedioPago)
                    WHERE   JSON_CONTAINS(pVentas, CONCAT(p.Codigo, ''), '$') AND p.Tipo = 'V'
                )
            ),
            (
                SELECT JSON_ARRAYAGG(CONCAT('$ ', MedioPago)) FROM MediosPago WHERE Estado = "A"
            ), NULL, NULL, NULL, NULL
    ORDER BY Fecha desc;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_inf_ventas;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;