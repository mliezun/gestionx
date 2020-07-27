DROP PROCEDURE IF EXISTS `xsp_borrar_linea_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_borrar_linea_existencia`(pToken varchar(500), pIdIngreso bigint, pIdArticulo bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
    /*
	Permite quitar una línea de ingreso a una existencia que se encuentre en estado En edición.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pNroLinea smallint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borrar_linea_existencia', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdIngreso = pIdIngreso AND Estado = 'E') THEN
        SELECT 'La existencia no está en modo edición.' Mensaje;
        LEAVE SALIR;
    END IF;
    IF NOT EXISTS (SELECT IdIngreso FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo) THEN
        SELECT 'La línea indicada no existe.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        INSERT INTO aud_LineasIngreso
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRAR', 'A', LineasIngreso.*
        FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;

        DELETE FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$

DELIMITER ;