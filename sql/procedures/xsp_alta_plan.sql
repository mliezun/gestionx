DROP PROCEDURE IF EXISTS `xsp_alta_plan`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_plan`(pPlan VARCHAR(50), pDias SMALLINT, pPrecio DECIMAL(10,2),pDescripcion VARCHAR(45))
PROC: BEGIN
	/*
	Da de alta un nuevo plan de suscripcion. Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdPlan SMALLINT;

	-- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'TRXERR' Mensaje;
        ROLLBACK;
	END;
    
	-- Los nombres de los planes son unicos
	IF EXISTS (SELECT IdPlan FROM Planes WHERE Plan = pPlan LIMIT 1)THEN
		START TRANSACTION;
			UPDATE Planes SET CantDias = pDias, Precio = pPrecio, Descripcion = pDescripcion, Estado = 'A'
			WHERE Plan = pPlan;
			SELECT CONCAT('OK', IdPlan) Mensaje FROM Planes WHERE Plan = pPlan;
		COMMIT;
		LEAVE PROC;
	END IF;

	-- El costo del plan debe ser 0 o mayor
	IF pPrecio IS NULL OR pPrecio < 0 THEN
		SELECT 'INVALIDPRICE' Mensaje;
		LEAVE PROC;
	END IF;

	-- Los dias a otorgar por el plan deben ser mayor que 0. El 0 esta reservado para el plan vitalicio
	IF pDias IS NULL OR pDias < 0 THEN
		SELECT 'INVALIDDAYSCOUNT' Mensaje;
		LEAVE PROC;
	END IF;

	START TRANSACTION;
		SET pIdPlan = (SELECT COALESCE(MAX(IdPlan), 0)+1 FROM Planes);

		INSERT INTO Planes
		SELECT		pIdPlan, pPlan, pDias, pPrecio, 'USD', pDescripcion, 'A';

		SELECT CONCAT('OK', pIdPlan) Mensaje;
	COMMIT;
END $$

DELIMITER ;