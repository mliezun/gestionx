DROP PROCEDURE IF EXISTS `xsp_alta_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_banco`(pToken varchar(500), pIdEmpresa int, pBanco varchar(100), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Banco.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdBanco smallint;
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
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_banco', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pBanco IS NULL OR TRIM(pBanco) = '') THEN
        SELECT 'Debe indicar el nombre del banco.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdBanco FROM Bancos WHERE Banco = pBanco AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe un banco con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Inserta
        INSERT INTO Bancos SELECT 0, pIdEmpresa, pBanco, 'A';
        SET pIdBanco = LAST_INSERT_ID();
		-- Audita
		INSERT INTO aud_Bancos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Bancos.* FROM Bancos WHERE IdBanco = pIdBanco;
        
        SELECT CONCAT('OK', pIdBanco) Mensaje;
	COMMIT;
END$$

DELIMITER ;