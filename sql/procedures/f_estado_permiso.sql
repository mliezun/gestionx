DROP FUNCTION IF EXISTS `f_estado_permiso`;
DELIMITER $$
CREATE FUNCTION `f_estado_permiso`(pIdPermiso int, pIdRol int) RETURNS char(1) CHARSET utf8 READS SQL DATA 
BEGIN
	/*
    Indica si el rol tiene permiso sobre el objeto.
    Si es hoja, puede tener permiso = 'S', o no = 'N'. Si no es hoja devuelve 'G'.
    */
	IF f_es_hoja_permiso(pIdPermiso) = 'S' THEN
		IF EXISTS(SELECT IdPermiso FROM PermisosRol WHERE IdPermiso = pIdPermiso AND IdRol = pIdRol) THEN
			RETURN 'S';
		ELSE
			RETURN 'N';
		END IF;
	ELSE
		RETURN 'G';
	END IF;
END$$

DELIMITER ;