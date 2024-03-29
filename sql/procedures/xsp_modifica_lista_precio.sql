DROP PROCEDURE IF EXISTS `xsp_modifica_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_lista_precio`(pToken varchar(500), pIdListaPrecio bigint,
pLista varchar(50), pPorcentaje decimal(10,4), pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar una Lista de precios existente controlando que el nombre de la lista no exista ya.
	Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario, pIdEmpresa bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pPorcentajeAntiguo decimal(10,4);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_lista_precio', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdListaPrecio IS NULL OR pIdListaPrecio = 0) THEN
        SELECT 'Debe ingresar la lista.' Mensaje;
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
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	-- Control de Parámetros incorrectos
    IF NOT EXISTS(SELECT IdListaPrecio FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio) THEN
		SELECT 'La lista indicada no existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    SET pIdEmpresa = (SELECT IdEmpresa FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio);
    IF EXISTS(SELECT Lista FROM ListasPrecio WHERE IdListaPrecio != pIdListaPrecio AND Lista = pLista AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre de la lista ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pPorcentajeAntiguo = (SELECT Porcentaje FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio);
        
        -- Antes
        INSERT INTO aud_ListasPrecio
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

        IF (pPorcentajeAntiguo != pPorcentaje) THEN
            -- Modifico el Historico
            UPDATE HistorialPorcentajes SET FechaFin = NOW() WHERE IdListaPrecio = pIdListaPrecio AND FechaFin IS NULL;
            -- Inserto Historico
            INSERT INTO HistorialPorcentajes
            SELECT 0, pIdListaPrecio, pPorcentaje, NOW(), NULL;

            -- Modifico el Historico Precios
            UPDATE HistorialPrecios hp
                INNER JOIN Articulos a USING(IdArticulo)
            SET FechaFin = NOW()
            WHERE FechaFin IS NULL
                AND a.IdEmpresa = pIdEmpresa;

            -- Audito PreciosArticulos Antes
            INSERT INTO aud_PreciosArticulos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_LISTA', 'A',
            PreciosArticulos.* FROM PreciosArticulos WHERE IdListaPrecio = pIdListaPrecio;

            -- Modifico los PreciosArticulos
            UPDATE      PreciosArticulos pa
            INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
            INNER JOIN  Articulos a USING(IdArticulo)
            INNER JOIN  Proveedores p USING(IdProveedor)
            SET         pa.PrecioVenta = f_calcular_precio_articulo(IdArticulo, p.Descuento, pPorcentaje)
            WHERE       lp.IdListaPrecio = pIdListaPrecio;

            UPDATE      HistorialPrecios hp
            SET         FechaFin = NOW()
            WHERE       hp.IdListaPrecio = pIdListaPrecio AND FechaFin IS NULL;

            INSERT INTO HistorialPrecios
            SELECT      0, IdArticulo, PrecioVenta, NOW(), NULL, IdListaPrecio
            FROM        PreciosArticulos
            WHERE       IdListaPrecio = pIdListaPrecio;

            -- Audita PreciosArticulos Despues
            INSERT INTO aud_PreciosArticulos
            SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA_LISTA', 'D',
            PreciosArticulos.* FROM PreciosArticulos WHERE IdListaPrecio = pIdListaPrecio;

            -- Inserto Historico Precios
            INSERT INTO HistorialPrecios
            SELECT 0, NULL, pa.PrecioVenta, NOW(), NULL, pIdListaPrecio
            FROM PreciosArticulos pa WHERE pa.IdListaPrecio;
        END IF;

        -- Modifica
        UPDATE  ListasPrecio 
		SET		Lista=pLista,
                Porcentaje=pPorcentaje,
                Observaciones=pObservaciones
		WHERE	IdListaPrecio=pIdListaPrecio;

        -- Despues
        INSERT INTO aud_ListasPrecio
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;