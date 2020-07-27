DROP PROCEDURE IF EXISTS `xsp_baja_plan`;
DELIMITER $$
CREATE PROCEDURE `xsp_baja_plan`(pToken varchar(128), pIdPlan SMALLINT, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
	/*
	Inhabilita un plan, colocando su estado en 'B'. Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario bigint;
	DECLARE pMensaje varchar(100);
	DECLARE pUsuario VARCHAR(120);

	-- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'TRXERR' Mensaje;
        ROLLBACK;
	END;

	-- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_baja_plan', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE PROC;
	END IF;
    
    IF NOT EXISTS (SELECT IdPlan FROM Planes WHERE IdPlan = pIdPlan) THEN
		SELECT 'NONEXISTENTPLAN' Mensaje;
		LEAVE PROC;
	END IF;

    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario LIMIT 1);
    
	START TRANSACTION;

		UPDATE Planes
		SET Estado = 'B'
		WHERE IdPlan = pIdPlan;

		SELECT CONCAT('OK', pIdPlan) Mensaje;
	COMMIT;
END $$

DELIMITER ;