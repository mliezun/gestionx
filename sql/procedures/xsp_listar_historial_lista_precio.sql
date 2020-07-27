DROP PROCEDURE IF EXISTS `xsp_listar_historial_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_historial_lista_precio`(pIdListaPrecio bigint)
SALIR: BEGIN
	/*
	Permite listar el historial de porcentajes de una lista de precios.
	*/
    SELECT  lp.Lista, hp.*
    FROM    ListasPrecio lp
    INNER JOIN HistorialPorcentajes hp USING(IdListaPrecio)
    WHERE   lp.IdListaPrecio = pIdListaPrecio
    ORDER BY FechaFin;
END$$

DELIMITER ;