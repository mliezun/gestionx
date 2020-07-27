DROP PROCEDURE IF EXISTS `xsp_activar_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_remito`(pToken varchar(500), pIdRemito bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del Remito a Activo siempre y cuando el estado actual sea Edicion.
	Devuelve OK o el mensaje de error en Mensaje.
    */
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_remito', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'A') THEN
		SELECT 'El remito ya está activo.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT Estado FROM Remitos WHERE IdRemito = pIdRemito AND Estado = 'E') THEN
		SELECT 'El remito debe estar en edición para poder ser activado.' Mensaje;
        LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Remitos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
		-- Activa Rol
		UPDATE Remitos SET Estado = 'A' WHERE IdRemito = pIdRemito;

		-- Instancia un nuevo ingreso
		CALL xsp_activar_existencia(pIdUsuario, (SELECT IdIngreso FROM Ingresos WHERE IdRemito=pIdRemito), pIP, pUserAgent, pAplicacion, pMensaje);
		IF pMensaje != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Aumenta la deuda al Proveedor
		CALL xsp_modificar_cuenta_corriente(pIdUsuario, 
			(SELECT IdProveedor FROM Remitos WHERE IdRemito = pIdRemito),
			'P',
			(	SELECT COALESCE(- SUM(li.Cantidad * li.Precio), 0)
				FROM Ingresos i
				INNER JOIN  LineasIngreso li USING(IdIngreso)
				WHERE i.IdRemito = pIdRemito),
			'Compra al Proveedor',
			NULL,
			pIP, pUserAgent, pAplicacion, pMensaje);
		IF SUBSTRING(pMensaje, 1, 2) != 'OK' THEN
			SELECT pMensaje Mensaje; 
			ROLLBACK;
			LEAVE SALIR;
		END IF;

		-- Después
		INSERT INTO aud_Remitos
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Remitos.* FROM Remitos WHERE IdRemito = pIdRemito;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;