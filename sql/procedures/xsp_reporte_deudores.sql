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

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_deudores;
    CREATE TEMPORARY TABLE tmp_inf_deudores
        SELECT      IF(cl.Tipo = 'F', CONCAT(cl.Nombres, ' ', cl.Apellidos), cl.RazonSocial) Cliente,
                    SUM(v.Monto) 'Monto Total',
                    COALESCE(SUM(COALESCE(p.Monto, 0)), 0) 'Monto Pagado',
                    SUM(v.Monto) - COALESCE(SUM(COALESCE(p.Monto, 0)), 0) Deuda,
                    GROUP_CONCAT(DISTINCT pv.PuntoVenta) `Punto de Venta`
        FROM        Ventas v
        INNER JOIN  Clientes cl USING(IdCliente)
        INNER JOIN  PuntosVenta pv ON v.IdPuntoVenta = pv.IdPuntoVenta
        LEFT JOIN   Pagos p ON p.Codigo = v.IdVenta AND p.Tipo = 'V'
        WHERE       v.IdEmpresa = pIdEmpresa
                    AND (v.Tipo IN ('P', 'V'))
                    AND (v.Estado IN ('A'))
                    AND (pIdCliente = 0 OR cl.IdCliente = pIdCliente)
        GROUP BY    cl.IdCliente
        ORDER BY    Cliente asc;

    SELECT  SUM(`Monto Total`), SUM(`Monto Pagado`), SUM(Deuda)
    INTO    pMontoTotal, pMontoPagado, pDeuda
    FROM    tmp_inf_deudores;

    SELECT 'TOTALES' Cliente, pMontoTotal 'Monto Total', pMontoPagado 'Monto Pagado',
            pDeuda Deuda, NULL `Punto de Venta`
    UNION
    SELECT * FROM tmp_inf_deudores;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_inf_deudores;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;