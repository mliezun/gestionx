DROP PROCEDURE IF EXISTS `xsp_eval`;
DELIMITER $$
CREATE PROCEDURE `xsp_eval`(pCadena text)
BEGIN
	/*
    Permite ejecutar una sentencia preparada leída de la base de datos, como implementación de polimorfismo.
    */
	SET @Cadena = pCadena;
    PREPARE STMT FROM @Cadena; 
    EXECUTE STMT;
    DEALLOCATE PREPARE STMT;
END$$

DELIMITER ;