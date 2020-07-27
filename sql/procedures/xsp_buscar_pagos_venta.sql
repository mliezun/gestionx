DROP PROCEDURE IF EXISTS `xsp_buscar_pagos_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_pagos_venta`(pIdVenta bigint, pIdMedioPago SMALLINT)
SALIR: BEGIN
    /*
	* Permite buscar los pagos de una venta. Se puede filtrar por medio de pago (0 para listar todos)
	*/
	SELECT p.*, mp.MedioPago, r.NroRemito, ch.NroCheque
    FROM        Pagos p 
    INNER JOIN  MediosPago mp USING(IdMedioPago)
    INNER JOIN  Ventas v ON v.IdVenta = p.Codigo AND p.Tipo = 'V'
    INNER JOIN  Clientes cl USING(IdCliente)
    LEFT JOIN   Remitos r ON p.IdRemito = r.IdRemito
    LEFT JOIN   Cheques ch ON p.IdCheque = ch.IdCheque
    WHERE       p.Codigo = pIdVenta
                AND (IdMedioPago = pIdMedioPago OR pIdMedioPago = 0)
    ORDER BY    p.FechaAlta;
END$$

DELIMITER ;