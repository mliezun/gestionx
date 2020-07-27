DROP PROCEDURE IF EXISTS `xsp_alta_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_puntoventa`(pToken varchar(500), pHost varchar(255), pPuntoVenta varchar(100),
pDatos text, pObservaciones varchar(255), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Punto Venta controlando que el nombre del punto venta 
	* no exista ya dentro de la misma empresa.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdPuntoVenta bigint;
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pIdEmpresa int;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_puntoventa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pHost IS NULL OR pHost = '') THEN
        SELECT 'Debe ingresar el url de la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPuntoVenta IS NULL OR pPuntoVenta = '') THEN
        SELECT 'Debe ingresar el nombre del punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pDatos IS NULL OR pDatos = '') THEN
        SELECT 'Debe ingresar los datos del punto de venta.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.URL = pHost) THEN
		SELECT 'Debe existir una empresa con el URL dado.' Mensaje;
		LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas E WHERE E.URL = pHost);
    IF EXISTS(SELECT PuntoVenta FROM PuntosVenta WHERE PuntoVenta = pPuntoVenta AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre del punto de venta ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO PuntosVenta SELECT 0, pIdEmpresa, pPuntoVenta, pDatos, 'A', pObservaciones;
		SET pIdPuntoVenta = LAST_INSERT_ID();
		-- Audita
		INSERT INTO aud_PuntosVenta
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', PuntosVenta.* FROM PuntosVenta WHERE IdPuntoVenta = pIdPuntoVenta;

		INSERT INTO ExistenciasConsolidadas
        SELECT      IdArticulo, pIdPuntoVenta, IdCanal, 0
        FROM        Articulos a
		CROSS JOIN  Canales c
        WHERE       a.IdEmpresa = pIdEmpresa AND c.IdEmpresa = pIdEmpresa;
        
        SELECT CONCAT('OK', pIdPuntoVenta) Mensaje;
	COMMIT;
END$$

DELIMITER ;