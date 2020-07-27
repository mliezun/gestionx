DROP PROCEDURE IF EXISTS `xsp_aplicar_aumento_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_aplicar_aumento_proveedor`(pToken varchar(500), pIdProveedor bigint, pAumento decimal(10,4),
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite aplicar un aumento a todos los artículos de un proveedor. Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
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
    IF (pAumento IS NULL) THEN
        SELECT 'El aumento del proveedor no puede estar vacío.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF NOT EXISTS (SELECT IdProveedor FROM Proveedores WHERE IdProveedor = pIdProveedor) THEN
        SELECT 'El proveedor indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        -- Modifico los PreciosArticulos
        UPDATE      PreciosArticulos pa
        INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
        INNER JOIN  Articulos a USING(IdArticulo)
        INNER JOIN  Proveedores p USING(IdProveedor)
        SET         pa.PrecioVenta = pa.PrecioVenta*IF(pAumento < 0, 1/(1+(-1*pAumento/100)), 1+(pAumento/100))
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
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;