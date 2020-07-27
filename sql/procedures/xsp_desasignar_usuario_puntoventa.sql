DROP PROCEDURE IF EXISTS `xsp_desasignar_usuario_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_desasignar_usuario_puntoventa`(pToken varchar(500), pIdUsuario bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
    Permite desasignar a un usuario del punto de venta.
	Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuarioAud bigint;
	DECLARE pUsuarioAud varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_desasignar_usuario_puntoventa', pMensaje, pIdUsuarioAud);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    -- Control de parámetros vacíos
    IF pIdUsuario IS NULL THEN
		SELECT 'Debe indicar un usuario.' Mensaje;
        LEAVE SALIR;
	END IF;
	START TRANSACTION;
		UPDATE UsuariosPuntosVenta SET Estado = 'B' WHERE IdUsuario = pIdUsuario;
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;