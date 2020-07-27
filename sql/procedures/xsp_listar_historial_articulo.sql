DROP PROCEDURE IF EXISTS `xsp_listar_historial_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_historial_articulo`(pIdArticulo bigint, pIdEmpresa bigint)
SALIR: BEGIN
	/*
	Permite listar el historial de precios de un articulo.
	*/
    SELECT  a.Articulo, lp.Lista, hp.*
    FROM    Articulos a
    INNER JOIN HistorialPrecios hp USING(IdArticulo)
    LEFT JOIN ListasPrecio lp USING(IdListaPrecio)
    WHERE   a.IdArticulo = pIdArticulo
            AND lp.IdEmpresa = pIdEmpresa
    ORDER BY FechaFin;
END$$

DELIMITER ;