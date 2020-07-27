DROP PROCEDURE IF EXISTS `xsp_borra_banco`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_banco`(pToken varchar(500), pIdBanco smallint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un banco controlando que no tenga ingresos o ventas asosiadas.
    * Devuelve OK o el mensaje de error en Mensaje.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_banco', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdBanco FROM Bancos WHERE IdBanco = pIdBanco) THEN
        SELECT 'El banco indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdCheque FROM Cheques WHERE IdBanco = pIdBanco) THEN
        SELECT 'El banco indicado no se puede borrar, tiene cheques asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_Bancos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Bancos.*
        FROM Bancos WHERE IdBanco = pIdBanco;
        -- Borro
        DELETE FROM Bancos WHERE IdBanco = pIdBanco;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;