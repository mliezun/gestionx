DROP PROCEDURE IF EXISTS `xsp_dame_pago`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_pago`(pIdPago bigint)
SALIR: BEGIN
    /*
	* Permite instanciar un pago desde la base de datos.
	*/
	SELECT p.*, mp.MedioPago, r.NroRemito, ch.NroCheque
    FROM Pagos p 
    INNER JOIN MediosPago mp USING(IdMedioPago)
    -- INNER JOIN Ventas v ON p.Codigo = v.IdVenta AND p.Tipo = 'V'
    -- INNER JOIN Clientes cl USING(IdCliente)
    LEFT JOIN  Remitos r ON p.IdRemito = r.IdRemito
    LEFT JOIN  Cheques ch ON p.IdCheque = ch.IdCheque
    WHERE p.IdPago = pIdPago;
END$$

DELIMITER ;