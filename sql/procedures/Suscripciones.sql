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

DROP PROCEDURE IF EXISTS `xsp_dame_suscripcion_por_datos`;

DELIMITER $$
CREATE PROCEDURE `xsp_dame_suscripcion_por_datos`(pDatos json)
BEGIN
    /*
    Permite instanciar una suscripción desde la base de datos a partir de los datos json.
    */
    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF pDatos->>'$.Proveedor' = 'Paypal' THEN
        SELECT  *
        FROM    Suscripciones
        WHERE   Datos->>'$.Proveedor' = 'Paypal' AND Datos->>'$.Mensaje.id' = pDatos->>'$.Mensaje.id';
    END IF;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_inicio_darbaja_suscripcion`;
DELIMITER $$
CREATE PROCEDURE `xsp_inicio_darbaja_suscripcion`(pToken varchar(128), pIdSuscripcion bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
    /*
    Coloca en estado 'F' (Pendiende de cancelación), a la suscripcion indicada.
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIdUsuario bigint;
    DECLARE pMensaje varchar(100);

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SELECT 'TRXERR' Mensaje;
        ROLLBACK;
	END;

    -- Validación de sesión
    CALL xsp_puede_ejecutar(pToken, 'xsp_inicio_darbaja_suscripcion', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE PROC;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
    
    IF NOT EXISTS (SELECT IdSuscripcion FROM Suscripciones WHERE IdUsuario = pIdEmpresa AND IdSuscripcion = pIdSuscripcion) THEN
		SELECT 'SUSCRNOTFOUND' Mensaje;
        LEAVE PROC;
    END IF;
    
    START TRANSACTION;   
        
        UPDATE  Suscripciones
        SET     Estado = 'F'
        WHERE   IdSuscripcion = pIdSuscripcion;
        
            
        SELECT 'OK' Mensaje;
	COMMIT;
END $$
DELIMITER ;

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

DROP PROCEDURE IF EXISTS `xsp_dame_suscripciones_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_suscripciones_usuario`(pIdusuario bigint)
BEGIN
    /*
    Permite obtener todas las suscripciones del usuario indicado.
    */
    SELECT * FROM Suscripciones WHERE IdUsuario = pIdusuario;
END $$
DELIMITER ;


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

DROP PROCEDURE IF EXISTS `xsp_listar_planes`;

DELIMITER $$
CREATE PROCEDURE `xsp_listar_planes`(pEstado CHAR(1))
BEGIN
    /*
    Devuelve listado de los planes, filtrando por estado.
    */
    SELECT IdPlan, Plan, CantDias, Precio, Descripcion, Estado
    FROM Planes
    WHERE Estado = pEstado;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_dame_plan`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_plan`(pIdPlan SMALLINT, pCodigoDesc CHAR(7))
PROC: BEGIN
	/*
	Busca un plan y devuelve los datos del plan. Si se indica un codigo de descuento,
	devuelve el precio final de utilizar ese codigo de descuento.
	La columna Descuento indica el valor total del descuento calculado.
	*/
	DECLARE pDescuentoPorcent TINYINT;

	IF pDescuentoPorcent IS NULL THEN
		SET pDescuentoPorcent = 0;
	END IF;

	SELECT IdPlan, Plan, CantDias, (Precio - (Precio * pDescuentoPorcent / 100)) Precio, (Precio * pDescuentoPorcent / 100) Descuento, Moneda, Descripcion
	FROM Planes
	WHERE IdPlan = pIdPlan
	AND Estado = 'A';

END $$
DELIMITER ;

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
