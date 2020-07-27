DROP PROCEDURE IF EXISTS `xsp_cargar_articulos_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_cargar_articulos_proveedor`(pToken varchar(500), pIdProveedor bigint, pArticulos json,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite hacer un alta/modifica masivo de artículos de un proveedor. Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion, pIdArticulo bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pDescuentoAntiguo, pDescuento decimal(10,4);
    DECLARE pIdHistorial bigint;
    DECLARE pIndice int default 0;
    DECLARE pArticuloJSON json;
    DECLARE pIdEmpresa int;
    DECLARE pArticulo, pCodigo varchar(255);
    DECLARE pDescripcion text;
    DECLARE pPrecioCosto, pPrecioCostoAntiguo decimal(12, 2);
    DECLARE pIdTipoIVA tinyint;
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
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Proveedores WHERE IdProveedor = pIdProveedor);
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        WHILE pIndice < JSON_LENGTH(pArticulos) DO
            SET pArticuloJSON = JSON_EXTRACT(pArticulos, CONCAT('$[', pIndice, ']'));

            SELECT  pArticuloJSON->>'$.Articulo', pArticuloJSON->>'$.Codigo', pArticuloJSON->>'$.Descripcion',
                    REPLACE(pArticuloJSON->>'$.PrecioCosto', ',', '.'), (SELECT IdTipoIVA FROM TiposIVA WHERE TipoIVA LIKE CONCAT('%', REPLACE(pArticuloJSON->>'$.IVA', ',', '.'), '%') ORDER BY 1 LIMIT 1)
            INTO    pArticulo, pCodigo, pDescripcion, pPrecioCosto, pIdTipoIVA;

            IF EXISTS (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor AND Codigo = pCodigo) THEN
                SET pIdArticulo = (SELECT IdArticulo FROM Articulos WHERE IdProveedor = pIdProveedor AND Codigo = pCodigo LIMIT 1);
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
                    -- Modifico el Historico
                    UPDATE HistorialPrecios SET FechaFin = NOW() WHERE IdArticulo = pIdArticulo AND FechaFin IS NULL;
                    -- Inserto Historico
                    INSERT INTO HistorialPrecios 
                    SELECT 0, pIdArticulo, pPrecioCosto, NOW(), NULL, NULL;

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
                END IF;

                -- Audita Articulos Despues
                INSERT INTO aud_Articulos
                SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
                Articulos.* FROM Articulos WHERE IdArticulo = pIdArticulo;
            ELSE
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
                INSERT INTO HistorialPrecios
                SELECT      0, pIdArticulo, pPrecioCosto, NOW(), NULL, NULL;

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
            END IF;

            SET pIndice = pIndice + 1;
        END WHILE;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;