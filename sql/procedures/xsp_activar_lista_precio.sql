DROP PROCEDURE IF EXISTS `xsp_activar_lista_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_lista_precio`(pToken varchar(500), pIdListaPrecio bigint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado de la Lista de Precio a Activo siempre y cuando no esté activo ya.
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_lista_precio', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio AND Estado = 'A') THEN
		SELECT 'La Lista ya está activada.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

		-- Antes
		INSERT INTO aud_ListasPrecio
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;

		-- Activa ListaPrecio
		UPDATE ListasPrecio SET Estado = 'A' WHERE IdListaPrecio = pIdListaPrecio;

		-- Después
		INSERT INTO aud_ListasPrecio
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
        ListasPrecio.* FROM ListasPrecio WHERE IdListaPrecio = pIdListaPrecio;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$

DELIMITER ;