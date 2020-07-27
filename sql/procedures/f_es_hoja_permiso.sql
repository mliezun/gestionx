DROP FUNCTION IF EXISTS `f_es_hoja_permiso`;
DELIMITER $$
CREATE FUNCTION `f_es_hoja_permiso`(pIdPermiso int) RETURNS char(1) CHARSET utf8 READS SQL DATA 
BEGIN
	/*
    Indica si el permiso es hoja (de último nivel = 'S') o bien agrupo otros permisos (nodo = 'N')
    */
	IF EXISTS(SELECT IdPermisoPadre FROM Permisos WHERE IdPermisoPadre = pIdPermiso) THEN
		RETURN 'N';
	ELSE
		RETURN 'S';
	END IF;
END$$

DELIMITER ;