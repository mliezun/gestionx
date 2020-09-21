DROP PROCEDURE IF EXISTS `xsp_activar_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_remito`(pToken varchar(500), pIdRemito bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del Remito a Activo siempre y cuando el estado actual sea Edicion o Ingresado.
	Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario, pIdProveedor bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pMontoLinea decimal(12, 2);
	DECLARE pDescripcion text;
    DECLARE pIndiceLinea int default 0;
    DECLARE pLineas json;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_remito', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'A') THEN
		SELECT 'El remito ya está activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado IN ('E', 'I')) THEN
		SELECT 'El remito debe estar en edición para poder ser activado.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- IF NOT EXISTS(SELECT NroRemito FROM Remitos WHERE IdRemito = pIdRemito AND NroRemito IS NOT NULL) THEN
	-- 	SELECT 'El remito debe tener Nro de Remito para poder ser activado.' Mensaje;
    --     LEAVE SALIR;
	-- END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Remitos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;

		IF NOT EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'I') THEN
			-- Si no fue ingresado activo el ingreso
			CALL xsp_activar_existencia(pIdUsuario, (SELECT IdIngreso FROM Ingresos WHERE IdRemito=pIdRemito), (SELECT IdCanal FROM Remitos WHERE IdRemito=pIdRemito), pIP, pUserAgent, pAplicacion, pMensaje);
			IF pMensaje != 'OK' THEN
				SELECT pMensaje Mensaje; 
				ROLLBACK;
				LEAVE SALIR;
			END IF;
		END IF;

		-- Busco las lineas venta asociados a la compra
		SET pLineas = ( SELECT  COALESCE(JSON_ARRAYAGG(li.NroLinea), JSON_ARRAY())
						FROM Ingresos i
						INNER JOIN  LineasIngreso li USING(IdIngreso)
						WHERE i.IdRemito = pIdRemito
		);
		SET pIdProveedor = (SELECT IdProveedor FROM Remitos WHERE IdRemito = pIdRemito);

		WHILE pIndiceLinea < JSON_LENGTH(pLineas) DO
			-- Aumento la deuda del Cliente
			SELECT		CONCAT(a.Articulo, ' x ', li.Cantidad), COALESCE(- (li.Cantidad * li.Precio), 0)
			INTO		pDescripcion, pMontoLinea
			FROM 		Ingresos i
			INNER JOIN  LineasIngreso li USING(IdIngreso)
			INNER JOIN  Articulos a ON li.IdArticulo = a.IdArticulo
			WHERE 		i.IdRemito = pIdRemito
						AND li.NroLinea = JSON_EXTRACT(pLineas, CONCAT('$[', pIndiceLinea, ']'));

			-- Aumenta la deuda al Proveedor
			CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
				pIdProveedor, 'P', pMontoLinea,
				'Compra', pDescripcion,
				pIP, pUserAgent, pAplicacion, pMensaje);
			IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
				SELECT pMensaje Mensaje; 
				ROLLBACK;
				LEAVE SALIR;
			END IF;

			SET pIndiceLinea = pIndiceLinea + 1;
		END WHILE;

		-- Activa Remito
		UPDATE Remitos SET Estado = 'A' WHERE IdRemito = pIdRemito;

		-- Después
		INSERT INTO aud_Remitos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;