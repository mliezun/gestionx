DROP PROCEDURE IF EXISTS `xsp_activar_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_articulo`(pToken varchar(500), pIdArticulo bigint,
    pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite activar un articulo controlando que no esté activo ya.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo AND Estado = 'A') THEN
        SELECT 'El artículo indicado ya se encuentra activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita Antes
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;

        -- Activa Articulo
        UPDATE  Articulos
        SET     Estado = 'A'
        WHERE   IdArticulo = pIdArticulo;

        -- Audita Despues
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;