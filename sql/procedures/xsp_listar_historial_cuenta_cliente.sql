DROP PROCEDURE IF EXISTS `xsp_listar_historial_cuenta_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_historial_cuenta_cliente`(pIdCliente bigint, pFechaInicio date, pFechaFin date)
SALIR: BEGIN
	/*
	Permite listar el historial de descuentos de un cliente.
	*/
    DECLARE pFechaAux date;
    SET pFechaInicio = COALESCE(pFechaInicio, '1900-01-01');
    SET pFechaFin = COALESCE(pFechaFin, '9999-12-31');
    IF pFechaFin < pFechaInicio THEN
        SET pFechaAux = pFechaFin;
        SET pFechaFin = pFechaInicio;
        SET pFechaInicio = pFechaAux;
    END IF;

    SELECT      c.IdCliente, hcc.*
    FROM        Clientes c
    INNER JOIN  CuentasCorrientes cc ON cc.IdEntidad = c.IdCliente AND cc.Tipo = 'C'
    INNER JOIN  HistorialCuentasCorrientes hcc USING(IdCuentaCorriente)
    WHERE       c.IdCliente = pIdCliente
                AND hcc.Fecha BETWEEN CONCAT(pFechaInicio, ' 00:00:00') AND CONCAT(pFechaFin, ' 23:59:59')
    ORDER BY 	hcc.Fecha DESC;
END$$

DELIMITER ;