DROP PROCEDURE IF EXISTS `xsp_buscar_pagos_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_pagos_proveedor`(pIdProveedor bigint, pIdMedioPago smallint, pFechaInicio date, pFechaFin date)
SALIR: BEGIN
    /*
	* Permite buscar los pagos a un provedor, entre 2 fechas.
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
    INNER JOIN  Proveedores pr ON pr.IdProveedor = p.Codigo AND p.Tipo = 'P'
    LEFT JOIN   Cheques ch ON p.IdCheque = ch.IdCheque
    WHERE       p.Codigo = pIdProveedor
                AND (IdMedioPago = pIdMedioPago OR pIdMedioPago = 0)
                AND p.FechaAlta BETWEEN CONCAT(pFechaInicio, ' 00:00:00') AND CONCAT(pFechaFin, ' 23:59:59')
    ORDER BY    p.FechaAlta;
END$$

DELIMITER ;