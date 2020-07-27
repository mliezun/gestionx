DROP PROCEDURE IF EXISTS `xsp_modifica_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_canal`(pToken varchar(500), pIdCanal bigint, pCanal varchar(50), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un Canal existente controlando que el nombre del Canal no exista ya dentro de la misma empresa.
	* Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario,pIdEmpresa bigint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_canal', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCanal IS NULL OR pIdCanal = 0) THEN
        SELECT 'Debe indicar el canal.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pCanal IS NULL OR TRIM(pCanal) = '') THEN
        SELECT 'Debe indicar el nombre del canal.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	-- Control de Parametros incorrectos
    IF EXISTS(SELECT IdCanal FROM Canales WHERE Canal = pCanal AND IdCanal != pIdCanal AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe otro canal con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        
        -- Antes
        INSERT INTO aud_Canales
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
        
        -- Modifica
        UPDATE Canales
		SET     Canal = pCanal,
                Observaciones = pObservaciones
		WHERE   IdCanal = pIdCanal;
		
        -- Despues
        INSERT INTO aud_Canales
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;