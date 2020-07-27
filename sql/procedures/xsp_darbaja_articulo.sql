DROP PROCEDURE IF EXISTS `xsp_darbaja_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_articulo`(pToken varchar(500), pIdArticulo bigint,
    pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite dar de baja un articulo controlando que no esté dado de baja ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo AND Estado = 'B') THEN
        SELECT 'El artículo indicado ya se encuentra dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Audita Antes
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;

        -- Da de Baja Articulo
        UPDATE  Articulos
        SET     Estado = 'B'
        WHERE   IdArticulo = pIdArticulo;

        -- Audita Despues
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Articulos.*
        FROM Articulos WHERE IdArticulo = pIdArticulo;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;