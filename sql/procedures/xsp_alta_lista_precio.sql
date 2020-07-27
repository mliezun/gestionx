DROP PROCEDURE IF EXISTS `xsp_alta_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_lista_precio`(pToken varchar(500), pIdEmpresa int, pLista varchar(50), pPorcentaje decimal(10,4), pObservaciones text, 
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta una lista de precios controlando que el nombre de la lista no exista ya dentro de la misma empresa.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdListaPrecio bigint;
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_lista_precio', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pLista IS NULL OR pLista = '') THEN
        SELECT 'Debe ingresar el nombre de la lista.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pPorcentaje IS NULL OR pPorcentaje = 0) THEN
        SELECT 'Debe ingresar el porcentaje de la lista.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir una empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Lista FROM ListasPrecio WHERE Lista = pLista AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre de la lista ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		
        -- Inserta Lista
        INSERT INTO ListasPrecio SELECT 0, pIdEmpresa, pLista, pPorcentaje, 'A', pObservaciones;

        SET pIdListaPrecio = LAST_INSERT_ID();

        -- Insercion de PreciosArticulos
        INSERT INTO PreciosArticulos
        SELECT      IdArticulo, pIdListaPrecio, NOW(), f_calcular_precio_articulo(IdArticulo, p.Descuento, pPorcentaje)
        FROM        Articulos a
        INNER JOIN  Proveedores p USING(IdProveedor)
        WHERE       a.IdEmpresa = pIdEmpresa;

        -- Insercion de Historial Precios
        INSERT INTO HistorialPrecios
        SELECT      0, pa.IdArticulo, pa.PrecioVenta, NOW(), NULL, pIdListaPrecio
        FROM        PreciosArticulos pa
        WHERE       pa.IdListaPrecio = pIdListaPrecio;

		-- Audito Insersiones
		INSERT INTO aud_ListasPrecio
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

        -- Inserta Historial
        INSERT INTO HistorialPorcentajes 
        SELECT 0, pIdListaPrecio, pPorcentaje, NOW(), NULL;
        
        SELECT CONCAT('OK', pIdListaPrecio) Mensaje;
	COMMIT;
END$$

DELIMITER ;