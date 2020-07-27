DROP PROCEDURE IF EXISTS `xsp_alta_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_existencia`(pIdUsuario bigint, pIdPuntoVenta bigint, pIdCliente bigint, pIdRemito bigint, pObservaciones text, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), out pMensaje text)
SALIR: BEGIN
    /*
	Permite ingresar existencias de un artículo a un punto de venta, ya sea por Remito o por nota de crédito (devolución de un cliente).
    Crea un ingreso en estado En edición, de manera que se le puedan agregar líneas.
    Devuelve OK+Id o el mensaje de error en Mensaje.
	*/
	DECLARE pIdIngreso bigint;
    DECLARE pIdEmpresa int;
    DECLARE pUsuario varchar(30);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;
    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
    INSERT INTO Ingresos SELECT 0, pIdPuntoVenta, pIdEmpresa, pIdCliente, pIdRemito, pIdUsuario, NOW(), 'E', pObservaciones;

    SET pIdIngreso = LAST_INSERT_ID();

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', Ingresos.*
    FROM Ingresos WHERE IdIngreso = pIdIngreso;

    SET pMensaje = CONCAT('OK', pIdIngreso);
END$$

DELIMITER ;