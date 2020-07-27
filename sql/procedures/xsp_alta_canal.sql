DROP PROCEDURE IF EXISTS `xsp_alta_canal`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_canal`(pToken varchar(500), pIdEmpresa int, pCanal varchar(50), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un canal controlando que el nombre del canal no exista ya dentro de la misma empresa.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdCanal bigint;
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_canal', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pCanal IS NULL OR TRIM(pCanal) = '') THEN
        SELECT 'Debe indicar el nombre del canal.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdCanal FROM Canales WHERE Canal = pCanal AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe un canal con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		        
        -- Inserta
        INSERT INTO Canales SELECT 0, pIdEmpresa, pCanal, 'A', pObservaciones;
        SET pIdCanal = LAST_INSERT_ID();
        
        -- Insercion de Existencias Consolidadas
        INSERT INTO ExistenciasConsolidadas
        SELECT      IdArticulo, IdPuntoVenta, pIdCanal, 0
        FROM        PuntosVenta pv
        CROSS JOIN  Articulos a
        WHERE       pv.IdEmpresa = pIdEmpresa AND a.IdEmpresa = pIdEmpresa;

		-- Audita
		INSERT INTO aud_Canales
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Canales.* FROM Canales WHERE IdCanal = pIdCanal;
        
        SELECT CONCAT('OK', pIdCanal) Mensaje;
	COMMIT;
END$$

DELIMITER ;