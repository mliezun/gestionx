DROP PROCEDURE IF EXISTS `xsp_dame_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_lista_precio`(pIdListaPrecio bigint)
BEGIN
	/*
    Procedimiento que sirve para instanciar una lista de precios desde la base de datos.
    */
	SELECT	*
    FROM	ListasPrecio
    WHERE	IdListaPrecio = pIdListaPrecio;
END$$

DELIMITER ;