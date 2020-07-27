DROP PROCEDURE IF EXISTS `xsp_activar_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_banco`(pToken varchar(500), pIdBanco smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado del Banco a Activo siempre y cuando no esté activo ya.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_banco', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Bancos WHERE IdBanco = pIdBanco AND Estado = 'A') THEN
		SELECT 'El Banco ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
		-- Activa Banco
		UPDATE Bancos SET Estado = 'A' WHERE IdBanco = pIdBanco;
		-- Después
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;