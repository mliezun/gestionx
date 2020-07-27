DROP PROCEDURE IF EXISTS `xsp_logout`;
DELIMITER $$
CREATE PROCEDURE `xsp_logout`(pJWT varchar(500))
PROC: BEGIN
	/*
    Permite actualizar la fecha de la última sesión abierta del usuario a la fecha actual.
    Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pIdSesion bigint;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		-- show errors;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
		ROLLBACK;
	END;
    IF NOT EXISTS (SELECT IdUsuario FROM Usuarios WHERE Token = pJWT) THEN
		SELECT 'OK' Mensaje;
        LEAVE PROC;
    END IF;
    SET pIdUsuario = (SELECT IdUsuario FROM Usuarios WHERE Token = pJWT);
	SET pIdSesion = (SELECT COALESCE(MAX(IdSesion), 0) FROM SesionesUsuarios WHERE IdUsuario = pIdUsuario);
    IF EXISTS (SELECT IdSesion FROM SesionesUsuarios WHERE IdSesion = pIdSesion AND FechaFin IS NOT NULL) THEN
		SELECT 'OK' Mensaje;
        LEAVE PROC;
    END IF;
    START TRANSACTION;
		UPDATE 	SesionesUsuarios
        SET		FechaFin = NOW()
        WHERE	IdSesion = pIdSesion;
        
        SELECT 'OK' Mensaje;
    COMMIT;
END$$

DELIMITER ;