DROP PROCEDURE IF EXISTS `xsp_listar_listas_precios_articulos`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_listas_precios_articulos`(pIdArticulo bigint)
SALIR: BEGIN
	/*
	Permite listar las listas de precios de un articulo desde la base de datos.
	*/
    SELECT  lp.Lista, pa.*
    FROM    Articulos a
    INNER JOIN PreciosArticulos pa USING(IdArticulo)
    INNER JOIN ListasPrecio lp USING(IdListaPrecio)
    WHERE   a.IdArticulo = pIdArticulo AND lp.Estado = 'A';
END$$

DELIMITER ;