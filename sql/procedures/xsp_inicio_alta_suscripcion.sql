DROP PROCEDURE IF EXISTS `xsp_inicio_alta_suscripcion`;
DELIMITER $$
CREATE PROCEDURE `xsp_inicio_alta_suscripcion`(pToken varchar(128), pIdPlan smallint, pRenovar char(1), pCodigoBonif char(7), pDatos json, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
	/*
	Registra el inicio del proceso de suscripcion del usuario. Si existe una suscripción Activa para el Usuario, retorna un mensaje de error.
	Si existe una suscripción Pendiente para el Usuario, actualiza las fechas de inicio y fin y los datos json, retorna OK+Id.
	En otro caso devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario, pIdSuscripcion, pIdEmpresa bigint;
	DECLARE pFechaInicio, pFechaFin date;
	DECLARE pMensaje varchar(100);
	DECLARE pDias SMALLINT;
	DECLARE pBonificado CHAR(1);

	-- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'TRXERR' Mensaje;
        ROLLBACK;
		SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	END;
	-- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_inicio_alta_suscripcion', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE PROC;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	-- Control de parámetros incorrectos
	SELECT CantDias INTO pDias FROM Planes where IdPlan = pIdPlan AND Estado = 'A';
	IF pDias IS NULL THEN
		SELECT 'INVALIDPLAN' Mensaje;
		LEAVE PROC;
	END IF;
	IF (pDias IS NULL OR pDias NOT IN (1, 7, 30, 365)) THEN
		SELECT 'INVALIDDAYSCOUNT' Mensaje;
		LEAVE PROC;
	END IF; 
	-- Control de única suscripción activa
	IF EXISTS (SELECT IdSuscripcion from Suscripciones where IdUsuario = pIdEmpresa AND Estado = 'A') THEN
		SELECT 'SUSCFOUNDERR' Mensaje;
		LEAVE PROC;
	END IF;  
	-- Seteo fechas de inicio y fin
	SET pFechaInicio = CURDATE();
	SET pFechaFin = pFechaInicio;
	IF(MOD(pDias,30) = 0) THEN
		set pFechaFin = date_add(pFechaFin, interval pdias/30 MONTH);
	ELSE
		set pFechaFin = date_add(pFechaFin, interval pdias day);
	END IF;
	-- Idempotencia
	IF EXISTS (SELECT IdSuscripcion FROM Suscripciones WHERE IdUsuario = pIdEmpresa AND Estado = 'P') THEN
		SELECT IdSuscripcion INTO pIdSuscripcion FROM Suscripciones WHERE IdUsuario = pIdEmpresa AND Estado = 'P';
		START TRANSACTION;
			UPDATE 	Suscripciones
			SET 	FechaInicio = pFechaInicio, FechaFin = pFechaFin, Datos = pDatos
			WHERE 	IdSuscripcion = pIdSuscripcion;

			SELECT CONCAT('OK', pIdSuscripcion) Mensaje;
		COMMIT;
		LEAVE PROC;
	END IF;

	START TRANSACTION;

		SET pIdSuscripcion = (SELECT COALESCE(MAX(IdSuscripcion), 0)+1 FROM Suscripciones);

		INSERT INTO Suscripciones
		SELECT pIdSuscripcion, pIdEmpresa, pIdPlan, pFechaInicio, pFechaFin, NULL, NULL, pRenovar, 'P', pBonificado, pCodigoBonif, pDatos;

		INSERT INTO Operaciones SELECT pIdSuscripcion, 'S', NULL, 1, NOW(6);

		SELECT CONCAT('OK', pIdSuscripcion) Mensaje;
	COMMIT;
END $$

DELIMITER ;