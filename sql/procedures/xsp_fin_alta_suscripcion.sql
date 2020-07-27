DROP PROCEDURE IF EXISTS `xsp_fin_alta_suscripcion`;

DELIMITER $$
CREATE PROCEDURE `xsp_fin_alta_suscripcion`(pDatos json)
PROC: BEGIN
	/*
	Hace efectiva la aprobacion de la suscripcion elegida. Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdSuscripcion bigint;
	DECLARE pIdUsuario BIGINT;
	DECLARE pEstado char(1);
	-- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'TRXERR' Mensaje;
        ROLLBACK;
		SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	END;
	IF pDatos IS NULL THEN
		SELECT 'TRXERR' Mensaje;
        LEAVE PROC;
	END IF;

	SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

	-- API Paypal
	IF pDatos->>'$.Proveedor' = 'Paypal' THEN
		IF pDatos->>'$.Tipo' IN ('A', 'W') THEN
			SELECT IdSuscripcion INTO pIdSuscripcion FROM Suscripciones WHERE Datos->>'$.Proveedor' = 'Paypal' AND Datos->>'$.Mensaje.id' = pDatos->>'$.Mensaje.id';
			SET pEstado = (CASE pDatos->>'$.Mensaje.status' WHEN 'ACTIVE' THEN 'A' WHEN 'APPROVAL_PENDING' THEN 'P' ELSE 'B' END);
			START TRANSACTION;
				UPDATE 	Suscripciones
				SET 	Estado = pEstado,
						Datos = pDatos,
						FechaFin = IF (pEstado = 'A', 
							COALESCE(CAST(SUBSTR(pDatos->>'$.Mensaje.billing_info.next_billing_time', 1, 10) AS DATE), CURDATE() + interval 7 day),
							FechaFin
						)
				WHERE 	IdSuscripcion = pIdSuscripcion;

				DELETE FROM Operaciones WHERE IdOperacion = pIdSuscripcion AND Tipo = 'S';

				SELECT 'OK' Mensaje;
			COMMIT;
		ELSE
			SELECT 'TRXERR' Mensaje;
		END IF;
	ELSE
		SELECT 'TRXERR' Mensaje;
	END IF;

	SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END $$

DELIMITER ;