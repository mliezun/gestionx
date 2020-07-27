DROP PROCEDURE IF EXISTS `xsp_darbaja_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_banco`(pToken varchar(500), pIdBanco smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de baja a un Banco siempre y cuando no esté dado de baja ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_banco', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Bancos WHERE IdBanco = pIdBanco AND Estado = 'B') THEN
		SELECT 'El Banco ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
		-- Activa Banco
		UPDATE Bancos SET Estado = 'B' WHERE IdBanco = pIdBanco;
		-- Después
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;