DROP PROCEDURE IF EXISTS `xsp_reporte_deudores`;
DELIMITER $$
CREATE PROCEDURE `xsp_reporte_deudores`(
    pIdEmpresa int,
    pIdCliente bigint
)
BEGIN
    DECLARE pMontoTotal, pMontoPagado, pDeuda DECIMAL(12, 2);
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET pIdCliente = COALESCE(pIdCliente, 0);

    IF pIdCliente = 0 THEN
        -- Resumen de todos los deudores de la empresa
        DROP TEMPORARY TABLE IF EXISTS tmp_inf_deudores;
        CREATE TEMPORARY TABLE tmp_inf_deudores
            SELECT      IF(cl.Tipo = 'F', CONCAT(cl.Nombres, ' ', cl.Apellidos), cl.RazonSocial) Cliente,
                        SUM(v.Monto) 'Monto Total',
                        COALESCE(tt1.Pagado, 0) 'Monto Pagado',
                        SUM(v.Monto) - COALESCE(tt1.Pagado, 0) Deuda,
                        GROUP_CONCAT(DISTINCT pv.PuntoVenta) `Punto de Venta`
            FROM        Ventas v
            INNER JOIN  Clientes cl USING(IdCliente)
            INNER JOIN  PuntosVenta pv ON v.IdPuntoVenta = pv.IdPuntoVenta
            INNER JOIN  (
                            SELECT      cl.IdCliente,
                                        COALESCE(SUM(COALESCE(p.Monto, 0)), 0) 'Pagado'
                            FROM        Ventas v
                            INNER JOIN  Clientes cl USING(IdCliente)
                            LEFT JOIN   Pagos p ON p.Codigo = v.IdVenta AND p.Tipo = 'V'
                            WHERE       v.IdEmpresa = pIdEmpresa
                                        AND (v.Tipo IN ('P', 'V'))
                                        AND (v.Estado NOT IN ('D'))
                            GROUP BY    cl.IdCliente
                        ) AS tt1 ON tt1.IdCliente = cl.IdCliente
            WHERE       v.IdEmpresa = pIdEmpresa
                        AND (v.Tipo IN ('P', 'V'))
                        AND (v.Estado NOT IN ('D'))
            GROUP BY    cl.IdCliente
            ORDER BY    Cliente asc;

        -- Calculo de totales acumulados
        SELECT  SUM(`Monto Total`), SUM(`Monto Pagado`), SUM(Deuda)
        INTO    pMontoTotal, pMontoPagado, pDeuda
        FROM    tmp_inf_deudores;

        -- Consulta final
        SELECT 'TOTALES' Cliente, pMontoTotal '$ Monto Total', pMontoPagado '$ Monto Pagado',
                pDeuda '$ Deuda', NULL `Punto de Venta`
        UNION
        SELECT * FROM tmp_inf_deudores;

        DROP TEMPORARY TABLE IF EXISTS tmp_inf_deudores;
    ELSE
        -- Consulta de deudor individual
        DROP TEMPORARY TABLE IF EXISTS tmp_inf_ventas_cliente;
        CREATE TEMPORARY TABLE tmp_inf_ventas_cliente
            /*IF(cl.Tipo = 'F', CONCAT(cl.Nombres, ' ', cl.Apellidos), cl.RazonSocial) Cliente*/
            SELECT      v.FechaAlta `Fecha`, 'Venta' Tipo,
                        CONCAT(a.Articulo, ' x ', lv.Cantidad, ' [', pr.Proveedor, ']') Descripcion,
                        (lv.Precio*lv.Cantidad) `$ Monto`
            FROM        Clientes cl
            INNER JOIN  Ventas v ON cl.IdCliente = v.IdCliente
            INNER JOIN  LineasVenta lv ON lv.IdVenta = v.IdVenta
            INNER JOIN  Articulos a ON lv.IdArticulo = a.IdArticulo
            INNER JOIN  Proveedores pr ON a.IdProveedor = pr.IdProveedor
            WHERE       cl.IdCliente = pIdCliente
                        AND (v.Tipo IN ('P', 'V'))
                        AND (v.Estado NOT IN ('D'));

        DROP TEMPORARY TABLE IF EXISTS tmp_inf_pagos_cliente;
        CREATE TEMPORARY TABLE tmp_inf_pagos_cliente
            /*IF(cl.Tipo = 'F', CONCAT(cl.Nombres, ' ', cl.Apellidos), cl.RazonSocial) Cliente*/
            SELECT      p.FechaAlta `Fecha`, 'Pago' Tipo,
                        mp.MedioPago Descripcion,
                        -p.Monto `$ Monto`
            FROM        Clientes cl
            INNER JOIN  Ventas v ON cl.IdCliente = v.IdCliente
            INNER JOIN  Pagos p ON v.IdVenta = p.Codigo AND p.Tipo = 'V'
            INNER JOIN  MediosPago mp ON p.IdMedioPago = mp.IdMedioPago
            WHERE       cl.IdCliente = pIdCliente
                        AND (v.Tipo IN ('P', 'V'))
                        AND (v.Estado NOT IN ('D'));

        DROP TEMPORARY TABLE IF EXISTS tmp_inf_deuda_cliente;
        CREATE TEMPORARY TABLE tmp_inf_deuda_cliente
            SELECT      *
            FROM        tmp_inf_ventas_cliente
            UNION ALL
            SELECT      *
            FROM        tmp_inf_pagos_cliente;

        SELECT SUM(`$ Monto`) INTO pDeuda FROM tmp_inf_deuda_cliente;

        SELECT  NOW() `Fecha`, 'Resumen' Tipo, 'Estado de cuenta' Descripcion,
                0 `$ Monto`, pDeuda `$ Deuda`
        UNION
        SELECT  *, SUM(`$ Monto`) over w '$ Deuda'
        FROM tmp_inf_deuda_cliente WINDOW w as (ORDER BY Fecha asc)
        ORDER BY    Fecha desc;

        DROP TEMPORARY TABLE IF EXISTS tmp_inf_ventas_cliente;
        DROP TEMPORARY TABLE IF EXISTS tmp_inf_pagos_cliente;
        DROP TEMPORARY TABLE IF EXISTS tmp_inf_deuda_cliente;
    END IF;

    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;