DROP PROCEDURE IF EXISTS `xsp_dame_cliente`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_cliente`(pIdCliente bigint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar un cliente desde la base de datos.
    */
	SELECT		c.*, lp.Lista, tda.TipoDocAfip, cc.Monto Deuda
    FROM		Clientes c
    INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
    INNER JOIN  TiposDocAfip tda USING(IdTipoDocAfip)
    INNER JOIN  CuentasCorrientes cc ON cc.IdEntidad = c.IdCliente AND cc.Tipo = 'C'
    WHERE	c.IdCliente = pIdCliente;
END$$

DELIMITER ;