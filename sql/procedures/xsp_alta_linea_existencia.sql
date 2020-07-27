DROP PROCEDURE IF EXISTS `xsp_alta_linea_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_linea_existencia`(pToken varchar(500), pIdIngreso bigint, pIdArticulo bigint, pCantidad decimal(10, 2), pPrecio decimal(10, 2), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
    /*
	Permite agregar una línea de ingreso a una existencia que se encuentre en estado En edición.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pNroLinea smallint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_linea_existencia', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdIngreso = pIdIngreso AND Estado = 'E') THEN
        SELECT 'La existencia no está en modo edición.' Mensaje;
        LEAVE SALIR;
    END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);

        IF EXISTS (SELECT IdIngreso FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo) THEN
            INSERT INTO aud_LineasIngreso
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'AGG', 'A', LineasIngreso.*
            FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;

            UPDATE LineasIngreso SET Cantidad = Cantidad + pCantidad WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;

            INSERT INTO aud_LineasIngreso
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'AGG', 'D', LineasIngreso.*
            FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND IdArticulo = pIdArticulo;
        ELSE
            SET pNroLinea = (SELECT COALESCE(MAX(NroLinea), 0) + 1 FROM LineasIngreso WHERE IdIngreso = pIdIngreso);

            INSERT INTO LineasIngreso SELECT pIdIngreso, pNroLinea, pIdArticulo, pCantidad, pPrecio;

            INSERT INTO aud_LineasIngreso
            SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', LineasIngreso.*
            FROM LineasIngreso WHERE IdIngreso = pIdIngreso AND NroLinea = pNroLinea;
        END IF;

        SELECT 'OK' Mensaje;
    COMMIT;
END$$

DELIMITER ;