DROP PROCEDURE IF EXISTS `xsp_buscar_pagos_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_pagos_cliente`(pIdCliente bigint, pIdMedioPago smallint, pFechaInicio date, pFechaFin date)
SALIR: BEGIN
    /*
	* Permite buscar los pagos de un cliente, entre 2 fechas.
    * Permitiendo filtrar por medio de pago (0 para listar todos).
	*/
    DECLARE pFechaAux date;
    SET pFechaInicio = COALESCE(pFechaInicio, '1900-01-01');
    SET pFechaFin = COALESCE(pFechaFin, '9999-12-31');
    IF pFechaFin < pFechaInicio THEN
        SET pFechaAux = pFechaFin;
        SET pFechaFin = pFechaInicio;
        SET pFechaInicio = pFechaAux;
    END IF;

    SELECT      p.*, mp.MedioPago, ch.NroCheque
    FROM        Pagos p 
    INNER JOIN  MediosPago mp USING(IdMedioPago)
    INNER JOIN  Clientes c ON c.IdCliente = p.Codigo AND p.Tipo = 'C'
    LEFT JOIN   Cheques ch ON p.IdCheque = ch.IdCheque
    WHERE       p.Codigo = pIdCliente
                AND (IdMedioPago = pIdMedioPago OR pIdMedioPago = 0)
                AND p.FechaAlta BETWEEN CONCAT(pFechaInicio, ' 00:00:00') AND CONCAT(pFechaFin, ' 23:59:59')
    ORDER BY    p.FechaAlta;
END$$

DELIMITER ;