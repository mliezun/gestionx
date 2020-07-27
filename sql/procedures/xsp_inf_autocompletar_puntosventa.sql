DROP procedure IF EXISTS `xsp_inf_autocompletar_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_autocompletar_puntosventa`(pIdEmpresa int, pCadena varchar(50))
BEGIN
	/*
    Permite buscar los puntos de venta dada una cadena de búsqueda que se autocompleta con el nombre del punto de venta que coincide con parte del nombre.
    Busca a partir de una cadena de más de 3 caracteres. Llena la lista del parámetro tipo A: Autocompletar de varios reportes.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
	SELECT		IdPuntoVenta Id, PuntoVenta Nombre
    FROM		PuntosVenta
    WHERE		IdEmpresa = pIdEmpresa AND Estado = 'A' AND
				(PuntoVenta LIKE CONCAT('%', pCadena, '%')) AND
				CHAR_LENGTH(pCadena) > 3
	ORDER BY	PuntoVenta;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;