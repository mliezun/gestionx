DROP PROCEDURE IF EXISTS `xsp_alta_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_articulo`(pToken varchar(500), pIdProveedor bigint, pIdEmpresa int,
    pArticulo varchar(255), pCodigo varchar(255), pDescripcion text, pPrecioCosto decimal(12, 2),
    pIdTipoIVA tinyint, pIP varchar(40), pUserAgent varchar(255),
    pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite dar de alta un articulo. Controlando que el nombre y el código del articulo no
    existan ya dentro del mismo proveedor. 
    Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pDescuento decimal(10,4);
    DECLARE pIdArticulo bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdProveedor IS NULL OR pIdProveedor = 0) THEN
        SELECT 'Debe indicar el proveedor.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe indicar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdTipoIVA IS NULL OR pIdTipoIVA = 0) THEN
        SELECT 'Debe indicar el tipo de IVA.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pArticulo IS NULL OR pArticulo = '') THEN
        SELECT 'El nombre del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pCodigo IS NULL OR pCodigo = '') THEN
        SELECT 'El código del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDescripcion IS NULL OR pDescripcion = '') THEN
        SELECT 'La descripción del artículo no puede estar vacía.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPrecioCosto IS NULL OR pPrecioCosto = 0) THEN
        SELECT 'El precio de costo del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa) THEN
        SELECT 'La empresa indicada no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdTipoIVA FROM TiposIVA WHERE IdTipoIVA = pIdTipoIVA) THEN
        SELECT 'El tipo de IVA indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdTipoIVA FROM TiposIVA
    WHERE IdTipoIVA = pIdTipoIVA AND FechaHasta IS NULL) THEN
        SELECT 'El tipo de IVA indicado no se encuentra vigente.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor AND Articulo = pArticulo) THEN
        SELECT 'Ya existe un artículo con ese nombre.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor AND Codigo = pCodigo) THEN
        SELECT 'Ya existe un artículo con ese código.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Insercion en Articulos
        INSERT INTO Articulos
        SELECT  0, pIdProveedor, pIdEmpresa, pIdTipoIVA, pArticulo, pCodigo, pDescripcion, pPrecioCosto, NOW(), 'A';

        SET pIdArticulo = LAST_INSERT_ID();

        -- Insercion de Existencias
        INSERT INTO ExistenciasConsolidadas
        SELECT      pIdArticulo, IdPuntoVenta, IdCanal, 0
        FROM        PuntosVenta pv
        CROSS JOIN  Canales c
        WHERE       pv.IdEmpresa = pIdEmpresa AND c.IdEmpresa = pIdEmpresa;

        SET pDescuento = (SELECT MAX(Descuento) FROM Proveedores WHERE IdProveedor = pIdProveedor);

        -- Insercion de Precios Articulos
        INSERT INTO PreciosArticulos
        SELECT      pIdArticulo, IdListaPrecio, NOW(), f_calcular_precio_articulo(pIdArticulo, pDescuento, lp.Porcentaje)
        FROM        ListasPrecio lp
        WHERE       lp.IdEmpresa = pIdEmpresa;

        -- Insercion de Historial Precios
        -- INSERT INTO HistorialPrecios
        -- SELECT      0, pIdArticulo, pPrecioCosto, NOW(), NULL, NULL;

        INSERT INTO HistorialPrecios
        SELECT      0, pIdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
        FROM        PreciosArticulos WHERE IdArticulo = pIdArticulo;
        
        -- Audita Inserciones
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;

        INSERT INTO aud_PreciosArticulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA_ARTICULO', 'I',
        PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;
		
        SELECT CONCAT('OK', pIdArticulo) Mensaje;
	COMMIT;
END$$

DELIMITER ;