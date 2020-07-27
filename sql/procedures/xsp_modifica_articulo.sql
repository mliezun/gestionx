DROP PROCEDURE IF EXISTS `xsp_modifica_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_articulo`(pToken varchar(500), pIdArticulo bigint,
    pArticulo varchar(255), pCodigo varchar(255), pDescripcion text, pPrecioCosto decimal(12, 2),
    pIdTipoIVA tinyint, pIP varchar(40), pUserAgent varchar(255),
    pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite cambiar el nombre, el código, la descripción, el precio por defecto de un articulo,
    verificando que no exista uno igual dentro del mismo proveedor.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pPrecioCostoAntiguo decimal(12,2);
    DECLARE pDescuento decimal(10,4);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_articulo', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
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
	IF (pIdTipoIVA IS NULL OR pIdTipoIVA = 0) THEN
        SELECT 'Debe indicar el tipo de IVA.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pPrecioCosto IS NULL OR pPrecioCosto = 0) THEN
        SELECT 'El precio de costo del artículo no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdArticulo FROM Articulos WHERE IdArticulo = pIdArticulo) THEN
        SELECT 'El artículo indicado no existe.' Mensaje;
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
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        SET pPrecioCostoAntiguo = (SELECT PrecioCosto FROM Articulos WHERE IdArticulo = pIdArticulo);

        -- Audita Articulos Antes
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;

        -- Modifica
        UPDATE  Articulos
        SET     Articulo = pArticulo,
                Codigo = pCodigo,
                Descripcion = pDescripcion,
                PrecioCosto = pPrecioCosto,
                IdTipoIVA = pIdTipoIVA
        WHERE   IdArticulo = pIdArticulo;

        IF (pPrecioCostoAntiguo != pPrecioCosto) THEN
            -- SET pDescuento = (SELECT MAX(p.Descuento) 
            -- FROM Proveedores p INNER JOIN Articulos a
            -- WHERE a.IdArticulo = pIdArticulo);

            -- Audito PreciosArticulos Antes
            INSERT INTO aud_PreciosArticulos
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_ARTICULO', 'A',
            PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

            -- Modifico los PreciosArticulos
            UPDATE      PreciosArticulos pa
            INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
            INNER JOIN  Articulos a USING(IdArticulo)
            INNER JOIN  Proveedores p USING(IdProveedor)
            SET         pa.PrecioVenta = f_calcular_precio_articulo(IdArticulo, p.Descuento, lp.Porcentaje)
            WHERE       IdArticulo = pIdArticulo;

            INSERT INTO HistorialPrecios
            SELECT 0, IdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
            FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

            -- Audita PreciosArticulos Despues
            INSERT INTO aud_PreciosArticulos
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_ARTICULO', 'D',
            PreciosArticulos.* FROM PreciosArticulos WHERE IdArticulo = pIdArticulo;

            -- Modifico el Historico
            UPDATE HistorialPrecios SET FechaFin = NOW() WHERE IdArticulo = pIdArticulo AND FechaFin IS NULL;
            
            -- Inserto Historico
            INSERT INTO HistorialPrecios
            SELECT      0, pIdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
            FROM        PreciosArticulos WHERE IdArticulo = pIdArticulo;

        END IF;

        -- Audita Articulos Despues
        INSERT INTO aud_Articulos
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;