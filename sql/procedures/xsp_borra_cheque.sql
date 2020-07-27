DROP PROCEDURE IF EXISTS `xsp_borra_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_cheque`(pToken varchar(500), pIdCheque bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un cheque controlando que no tenga ingresos o ventas asosiadas.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_cheque', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdCheque FROM Cheques WHERE IdCheque = pIdCheque) THEN
        SELECT 'El cheque indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdCheque FROM Pagos WHERE IdCheque = pIdCheque) THEN
        SELECT 'El cheque indicado no se puede borrar, tiene pagos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdCheque FROM PagosProveedor WHERE IdCheque = pIdCheque) THEN
        SELECT 'El cheque indicado no se puede borrar, tiene pagos de proveedores asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_Cheques
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Cheques.*
        FROM Cheques WHERE IdCheque = pIdCheque;
        -- Borro
        DELETE FROM Cheques WHERE IdCheque = pIdCheque;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;