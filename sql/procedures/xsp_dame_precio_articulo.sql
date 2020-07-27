DROP PROCEDURE IF EXISTS `xsp_dame_precio_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_precio_articulo`(pIdArticulo bigint, pIdListaPrecio bigint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un precio articulo desde la base de datos.
    */
	SELECT	*
    FROM	PreciosArticulos
    WHERE	IdArticulo = pIdArticulo AND IdListaPrecio = pIdListaPrecio;
END$$

DELIMITER ;