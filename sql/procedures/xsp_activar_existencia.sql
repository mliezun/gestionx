DROP PROCEDURE IF EXISTS `xsp_activar_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_existencia`(pIdUsuario bigint, pIdIngreso bigint, pIdCanal bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), out pMensaje text)
SALIR: BEGIN
    /*
	Permite activar una existencia, controlando que tenga al menos una línea.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
    DECLARE pUsuario varchar(30);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;

    IF pIdIngreso IS NULL OR pIdIngreso = 0 THEN
        SET pMensaje = 'Debe indicar los artículos a ingresar.';
        LEAVE SALIR;
    END IF;

    IF NOT EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdIngreso = pIdIngreso AND Estado = 'E') THEN
        SET pMensaje = 'No se puede activar, no está en modo edición.';
        LEAVE SALIR;
    END IF;

    IF NOT EXISTS (
                SELECT      IdIngreso
                FROM        LineasIngreso li 
                WHERE       li.IdIngreso = pIdIngreso
            ) THEN
        SET pMensaje = 'No se puede activar, no tiene líneas de ingreso asociadas.';
        LEAVE SALIR;
    END IF;

    UPDATE      ExistenciasConsolidadas ec
    INNER JOIN  Ingresos i USING(IdPuntoVenta)
    INNER JOIN  LineasIngreso li USING(IdIngreso, IdArticulo)
    SET         ec.Cantidad = ec.Cantidad + li.Cantidad
    WHERE       i.IdIngreso = pIdIngreso
                AND ec.IdCanal = pIdCanal;

    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
    Ingresos.* FROM Ingresos WHERE IdIngreso = pIdIngreso;

    UPDATE Ingresos SET Estado = 'A' WHERE IdIngreso = pIdIngreso;

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D',
    Ingresos.* FROM Ingresos WHERE IdIngreso = pIdIngreso;

    SET pMensaje = 'OK';
END$$

DELIMITER ;