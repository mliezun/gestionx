DROP PROCEDURE IF EXISTS `xsp_dame_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_cliente`(pIdCliente bigint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar un cliente desde la base de datos.
    */
	SELECT		c.*, lp.Lista, tda.TipoDocAfip
    FROM		Clientes c
    INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
    INNER JOIN  TiposDocAfip tda USING(IdTipoDocAfip)
    WHERE	c.IdCliente = pIdCliente;
END$$

DELIMITER ;