DROP PROCEDURE IF EXISTS `xsp_modifica_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_banco`(pToken varchar(500), pIdBanco smallint, pBanco varchar(100),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un Banco.
	* Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_banco', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdBanco IS NULL OR pIdBanco = 0) THEN
        SELECT 'Debe indicar el banco.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pBanco IS NULL OR TRIM(pBanco) = '') THEN
        SELECT 'Debe indicar el nombre del banco.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF EXISTS(SELECT IdBanco FROM Bancos WHERE Banco = pBanco AND IdEmpresa = pIdEmpresa AND IdBanco != pIdBanco) THEN
		SELECT 'Ya existe otro banco con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_Bancos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', Bancos.*
        FROM Bancos WHERE IdBanco = pIdBanco;
        -- Modifica
        UPDATE Bancos 
		SET	   Banco = pBanco
		WHERE  IdBanco=pIdBanco;
		-- Despues
        INSERT INTO aud_Bancos
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', Bancos.*
        FROM Bancos WHERE IdBanco = pIdBanco;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;