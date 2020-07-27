DROP PROCEDURE IF EXISTS `xsp_alta_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_destino_cheque`(pToken varchar(500), pIdEmpresa int,
pDestino varchar(100), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un destino de cheque controlando que el nombre del destino no exista ya.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdDestinoCheque smallint;
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_destino_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDestino IS NULL OR pDestino = '') THEN
        SELECT 'Debe ingresar el destino.' Mensaje;
        LEAVE SALIR;
	END IF;

	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdDestinoCheque FROM DestinosCheque WHERE Destino = pDestino AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe un destino con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO DestinosCheque SELECT 0, pIdEmpresa, pDestino, 'A';
        SET pIdDestinoCheque = LAST_INSERT_ID();
        -- Audita
		INSERT INTO aud_DestinosCheque
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
        
        SELECT CONCAT('OK', pIdDestinoCheque) Mensaje;
	COMMIT;
END$$

DELIMITER ;