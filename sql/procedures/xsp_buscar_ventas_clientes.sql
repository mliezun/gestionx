DROP PROCEDURE IF EXISTS `xsp_buscar_ventas_clientes`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_ventas_clientes`(pIdEmpresa int, pIdCliente bigint, pFechaInicio date, pFechaFin date, pEstado char(1), pEstadoVenta char(1), pMora char(1))
BEGIN
	/*
    Permite buscar entre todos los movimientos de un cliente, entre 2 fechas, permitiendo filtrar los
    clientes por su estado con pEstado y filtrar las ventas por su estado con pEstadoVenta.
    Permitiendo ver cuáles están en mora con pMora [S|N].
    */
    SET pFechaInicio = COALESCE(pFechaInicio, NOW() - INTERVAL 1 YEAR);
    SET pFechaFin = COALESCE(pFechaFin, NOW());
    SET pMora = COALESCE(pMora, 'N');

    SELECT		c.*, v.IdVenta, v.Monto, v.Tipo TipoVenta, v.FechaAlta FechaAltaVenta,
                v.Estado EstadoVenta, v.Observaciones ObservacionesVenta, v.IdPuntoVenta,
                GROUP_CONCAT('[', JSON_OBJECT(
                    'IdPago', p.IdPago,
                    'IdMedioPago', p.IdMedioPago,
                    'MedioPago', (SELECT MedioPago FROM MediosPago WHERE IdMedioPago = p.IdMedioPago),
                    'FechaAlta', p.FechaAlta,
                    'FechaDebe', p.FechaDebe,
                    'FechaPago', p.FechaPago,
                    'FechaAnula', p.FechaAnula,
                    'Monto', p.Monto,
                    'Observaciones', p.Observaciones,
                    'IdCheque', p.IdCheque,
                    'NroTarjeta', p.NroTarjeta,
                    'MesVencimiento', p.MesVencimiento,
                    'AnioVencimiento', p.AnioVencimiento,
                    'CCV', p.CCV
                ), ']') Pagos, SUM(COALESCE(p.Monto, 0)) MontoPagos
    FROM        Clientes c
    INNER JOIN  Ventas v USING(IdCliente)
    LEFT JOIN   Pagos p ON v.IdVenta = p.Codigo AND p.Tipo = 'V'
    WHERE       v.IdEmpresa = pIdEmpresa AND (pIdCliente = 0 OR c.IdCliente = pIdCliente)
                AND (c.Estado = pEstado OR pEstado = 'T')
                AND (v.Estado = pEstadoVenta OR pEstadoVenta = 'T')
                AND (v.FechaAlta BETWEEN pFechaInicio AND (pFechaFin + INTERVAL 1 DAY))
    GROUP BY    c.IdCliente, v.IdVenta
    HAVING      pMora = 'N' OR (v.Estado = 'A' AND v.Monto > SUM(COALESCE(p.Monto, 0)))
    ORDER BY    v.FechaAlta DESC; -- pMora = 'S' => (MontoVenta < SUM(MontoPago))
END$$

DELIMITER ;