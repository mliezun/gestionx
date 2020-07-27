DROP PROCEDURE IF EXISTS `xsp_fin_darbaja_suscripcion`;
DELIMITER $$
CREATE PROCEDURE `xsp_fin_darbaja_suscripcion`(pIdSuscripcion bigint)
PROC: BEGIN
    /*
    Coloca en estado 'C' (Cancelada), a la suscripcion indicada.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'TRXERR' Mensaje;
        ROLLBACK;
	END;
    
    IF NOT EXISTS (SELECT IdSuscripcion FROM Suscripciones WHERE IdSuscripcion = pIdSuscripcion) THEN
		SELECT 'SUSCRNOTFOUND' Mensaje;
        LEAVE PROC;
    END IF;
    
    START TRANSACTION;   
        
        UPDATE  Suscripciones
        SET     FechaBaja = CURDATE(),
                AgenteBaja = 'U',
                Renovar = 'N',
                Estado = 'C'
        WHERE   IdSuscripcion = pIdSuscripcion;

        DELETE FROM Operaciones WHERE IdOperacion = pIdSuscripcion AND Tipo = 'S';
            
        SELECT 'OK' Mensaje;
	COMMIT;
END $$

DELIMITER ;