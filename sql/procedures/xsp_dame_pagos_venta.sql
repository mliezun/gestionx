DROP PROCEDURE IF EXISTS `xsp_dame_pagos_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_pagos_venta`(pIdVenta bigint)
SALIR: BEGIN
    /*
	* Permite listar los pagos de una venta.
	*/
	SELECT      p.*, mp.MedioPago, r.NroRemito, ch.NroCheque
    FROM        Ventas v 
    INNER JOIN  Pagos p ON p.Codigo = v.IdVenta AND p.Tipo = 'V'
    INNER JOIN  MediosPago mp USING(IdMedioPago)
    INNER JOIN  Clientes cl USING(IdCliente)
    LEFT JOIN   Remitos r ON p.IdRemito = r.IdRemito
    LEFT JOIN   Cheques ch ON p.IdCheque = ch.IdCheque
    WHERE       p.Codigo = pIdVenta
    ORDER BY    p.FechaAlta;
END$$

DELIMITER ;