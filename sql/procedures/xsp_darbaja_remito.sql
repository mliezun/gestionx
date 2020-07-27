DROP PROCEDURE IF EXISTS `xsp_darbaja_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_remito`(pToken varchar(500), pIdRemito bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del Remito siempre y cuando no esté dado de baja ya.
	Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_remito', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'B') THEN
		SELECT 'El remito ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Remitos
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','A',Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
		-- Da de baja
		UPDATE Remitos SET Estado = 'B' WHERE IdRemito = pIdRemito;

		CALL xsp_darbaja_existencia(pIdUsuario, (SELECT IdIngreso FROM Ingresos WHERE IdRemito=pIdRemito), pIP, pUserAgent, pAplicacion, pMensaje);
		IF pMensaje != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Después
		INSERT INTO aud_Remitos
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','D',Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;