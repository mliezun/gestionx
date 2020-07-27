DROP PROCEDURE IF EXISTS `xsp_modifica_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_proveedor`(pToken varchar(500), pIdProveedor bigint, pProveedor varchar(100), pDescuento decimal(10,4),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite dar de alta un proveedor. Controlando que el nombre del proveedor no exista ya
    dentro de la misma empresa. Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    DECLARE pDescuentoAntiguo decimal(10,4);
    DECLARE pIdHistorial bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_proveedor', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pProveedor IS NULL OR pProveedor = '') THEN
        SELECT 'El nombre del proveedor no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pDescuento IS NULL) THEN
        SELECT 'El descuento del proveedor no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor != pIdProveedor AND Proveedor = pProveedor) THEN
        SELECT 'Ya existe un proveedor con ese nombre.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        SET pDescuentoAntiguo = (SELECT Descuento FROM Proveedores WHERE IdProveedor = pIdProveedor);

        -- Audito Antes
        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A',
        Proveedores.* FROM Proveedores WHERE IdProveedor = pIdProveedor;

        -- Modifico Proveedor
        UPDATE Proveedores 
            SET Proveedor = pProveedor,
                Descuento = pDescuento
        WHERE IdProveedor = pIdProveedor;

        -- Audito Despues
        INSERT INTO aud_Proveedores
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        Proveedores.* FROM Proveedores WHERE IdProveedor = pIdProveedor;

        IF (pDescuentoAntiguo != pDescuento) THEN
            SET pIdHistorial = (SELECT IdHistorial FROM HistorialDescuentos WHERE IdProveedor = pIdProveedor AND FechaFin IS NULL);
            -- Modifico el Historico
            UPDATE HistorialDescuentos SET FechaFin = NOW() WHERE IdHistorial = pIdHistorial AND FechaFin IS NULL;
            -- Inserto Historico
            INSERT INTO HistorialDescuentos SELECT 0, pIdProveedor, pDescuento, NOW(), NULL;

            -- Modifico los PreciosArticulos
            UPDATE      PreciosArticulos pa
            INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
            INNER JOIN  Articulos a USING(IdArticulo)
            INNER JOIN  Proveedores p USING(IdProveedor)
            SET         pa.PrecioVenta = f_calcular_precio_articulo(IdArticulo, p.Descuento, lp.Porcentaje)
            WHERE       a.IdProveedor = pIdProveedor;

            UPDATE      HistorialPrecios hp
            INNER JOIN  PreciosArticulos pa USING(IdArticulo)
            INNER JOIN  Articulos a USING(IdArticulo)
            SET         FechaFin = NOW()
            WHERE       a.IdProveedor = pIdProveedor AND FechaFin IS NULL AND hp.IdListaPrecio IS NOT NULL;

            INSERT INTO HistorialPrecios
            SELECT      0, a.IdArticulo, pa.PrecioVenta, NOW(), NULL, pa.IdListaPrecio
            FROM        PreciosArticulos pa
            INNER JOIN  Articulos a USING(IdArticulo)
            WHERE       a.IdProveedor = pIdProveedor;
        END IF;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;