DROP PROCEDURE IF EXISTS `xsp_darbaja_existencia`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_existencia`(pIdUsuario bigint, pIdIngreso bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), out pMensaje text)
SALIR: BEGIN
    /*
	Permite quitar existencias, controlando que existan la cantidad de existencias
    consolidadas suficientes para realizar esa acción.
    Devuelve OK o el mensaje de error en Mensaje.
	*/
    DECLARE pUsuario varchar(30);
    DECLARE pIdEmpresa int;
    DECLARE pIdCanal bigint;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;

    IF pIdIngreso IS NULL OR pIdIngreso = 0 THEN
        SET pMensaje = 'Debe indicar los artículos a remover.';
        LEAVE SALIR;
    END IF;

    IF (SELECT IdRemito FROM Ingresos WHERE IdIngreso = pIdIngreso) IS NULL THEN
        -- Es un ingreso de Cliente
        SET pIdCanal = (
            SELECT      v.IdCanal
            FROM        Ventas v
            INNER JOIN  Pagos p ON p.Codigo = v.IdVenta AND p.Tipo = 'V'
            INNER JOIN  Ingresos i ON p.IdMedioPago = 2 AND p.Datos->>'$.IdIngreso' = i.IdIngreso
            WHERE       i.IdIngreso = pIdIngreso
        );
    ELSE
        -- Es un ingreso de Remito
        SET pIdCanal = (SELECT r.IdCanal FROM Ingresos i INNER JOIN Remitos r USING(IdRemito) WHERE i.IdIngreso = pIdIngreso);
    END IF;

    IF NOT EXISTS (
                SELECT      ec.IdArticulo
                FROM        LineasIngreso li 
                INNER JOIN  Ingresos i USING(IdIngreso)
                INNER JOIN  ExistenciasConsolidadas ec USING(IdArticulo, IdPuntoVenta)
                WHERE       i.IdIngreso = pIdIngreso AND i.Estado = 'A'
                            AND ec.IdCanal = pIdCanal
                GROUP BY    IdArticulo
                HAVING      SUM(li.Cantidad) < SUM(ec.Cantidad) 
            ) THEN
        SET pMensaje = 'No hay suficientes existencias de los artículos que intenta borrar.';
        LEAVE SALIR;
    END IF;

    IF EXISTS (SELECT IdIngreso FROM Ingresos WHERE IdIngreso = pIdIngreso AND Estado = 'A') THEN
        UPDATE      ExistenciasConsolidadas ec
        INNER JOIN  Ingresos i USING(IdPuntoVenta)
        INNER JOIN  LineasIngreso li USING(IdIngreso, IdArticulo)
        SET         ec.Cantidad = ec.Cantidad - li.Cantidad
        WHERE       i.IdIngreso = pIdIngreso AND i.Estado = 'A'
                    AND ec.IdCanal = pIdCanal;
    END IF;

    SET pIdEmpresa = (SELECT IdEmpresa FROM Ingresos WHERE IdIngreso = pIdIngreso);
    IF NOT((SELECT FechaAlta FROM Ingresos WHERE IdIngreso = pIdIngreso) <  NOW() + 
    SEC_TO_TIME(60*(SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'MAXTIEMPOANULACION' AND IdModulo = 1)) ) THEN
        SET pMensaje = 'El ingreso supero el tiempo maximo de anulacion.';
        LEAVE SALIR;
    END IF;

    SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Ingresos.*
    FROM Ingresos WHERE IdIngreso = pIdIngreso;

    UPDATE Ingresos SET Estado = 'B' WHERE IdIngreso = pIdIngreso;

    INSERT INTO aud_Ingresos
    SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Ingresos.*
    FROM Ingresos WHERE IdIngreso = pIdIngreso;

    SET pMensaje = 'OK';
    
END$$

DELIMITER ;