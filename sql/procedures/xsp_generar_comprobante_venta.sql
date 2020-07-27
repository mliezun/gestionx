DROP PROCEDURE IF EXISTS `xsp_generar_comprobante_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_generar_comprobante_venta`(pIdVenta bigint)
SALIR: BEGIN
    /*
	* Permite obtener los datos para generar un comprobante de Venta.
	*/
    DECLARE pIdEmpresa int;
    DECLARE pNroComprobante int;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
        SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
	END;

    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DROP TEMPORARY TABLE IF EXISTS tmp_comprobante;

    CREATE TEMPORARY TABLE tmp_comprobante ENGINE=MEMORY
	SELECT      v.IdVenta, v.IdPuntoVenta, v.IdEmpresa, v.IdCliente, v.IdUsuario,	
	            v.IdTipoTributo, v.IdCanal,	v.Monto, v.FechaAlta, v.Tipo,
	            v.Estado, v.Observaciones, c.IdListaPrecio, c.IdTipoDocAfip,
	            c.Nombres, c.Apellidos, c.RazonSocial, c.Documento, c.Datos,
	            c.FechaAlta FechaAltaCliente, c.Tipo TipoCliente,
                c.Observaciones ObservacionesCliente, c.Estado EstadoCliente,
                pv.Datos->>'$.NroPuntoVenta' NroPuntoVenta,
                JSON_ARRAYAGG(JSON_OBJECT(
                        'Articulo', a.Articulo,
                        'Codigo', a.Codigo,
                        'Cantidad', lv.Cantidad,
                        'Precio', lv.Precio,
                        'Subtotal', CAST(lv.Cantidad * lv.Precio AS DECIMAL(12, 2)),
                        'ImporteIVA', CAST(CAST(lv.Cantidad * lv.Precio AS DECIMAL(12, 2)) * (SELECT 1-1/(1+Porcentaje/100) FROM TiposIVA WHERE IdTipoIVA = a.IdTipoIVA) AS DECIMAL(12, 2)),
                        'IdTipoIVA', a.IdTipoIVA,
                        -- Tipo de Unidad (u)
                        'Unidad', 7
                    )) Articulos, CAST(SUM(lv.Precio * lv.Cantidad) AS DECIMAL(12, 2)) Total,
                IF(c.Tipo = 'F', CONCAT(c.Apellidos, ', ', c.Nombres), c.RazonSocial) NombreCliente,
                IF(v.Estado = 'D', 
                    -- THEN
                    v.IdTipoComprobanteAfip+2,
                    -- ELSE
                    v.IdTipoComprobanteAfip
                ) IdTipoComprobanteAfip, 0 IdComprobanteAfip, 0 NroComprobante, NOW() FechaGenerado,
                IF(v.Estado = 'D', 
                    -- THEN
                    (SELECT JSON_OBJECT(
                                'IdComprobanteAfip', IdComprobanteAfip,
                                'NroComprobante', NroComprobante,
                                'IdTipoComprobanteAfip', IdTipoComprobanteAfip,
                                'FechaGenerado', FechaGenerado
                            )
                    FROM    ComprobantesVentas
                    WHERE   IdVenta = v.IdVenta
                            AND IdTipoComprobanteAfip = v.IdTipoComprobanteAfip
                    LIMIT   1),
                    -- ELSE
                    NULL
                ) ComprobanteAfipOriginal,
                (
                    SELECT  JSON_OBJECTAGG(IdTipoDocAfip, TipoDocAfip)
                    FROM    TiposDocAfip
                    WHERE   FechaHasta IS NULL
                ) TiposDocAfip
    FROM        Ventas v
    INNER JOIN  Clientes c USING(IdCliente)
    INNER JOIN  LineasVenta lv USING(IdVenta)
    INNER JOIN  Articulos a USING(IdArticulo)
    INNER JOIN  PuntosVenta pv USING(IdPuntoVenta)
    WHERE       v.IdVenta = pIdVenta AND v.Estado IN ('P', 'D', 'A')
    GROUP BY    v.IdVenta;

    START TRANSACTION;
        IF EXISTS (SELECT 1 FROM ComprobantesVentas INNER JOIN tmp_comprobante USING(IdVenta,IdTipoComprobanteAfip)) THEN
            UPDATE      tmp_comprobante t
            INNER JOIN  ComprobantesVentas c USING(IdVenta,IdTipoComprobanteAfip)
            SET         t.IdComprobanteAfip = c.IdComprobanteAfip, t.NroComprobante = c.NroComprobante, t.FechaGenerado = c.FechaGenerado;
        ELSEIF (SELECT 1 FROM tmp_comprobante WHERE Tipo = 'V') THEN -- es una venta
            SET pIdEmpresa = (SELECT IdEmpresa FROM Ventas WHERE IdVenta = pIdVenta);
            SET pNroComprobante = (SELECT Valor FROM ParametroEmpresa WHERE IdEmpresa = pIdEmpresa AND Parametro = 'NUMEROCOMPROBANTE' FOR UPDATE);

            INSERT INTO ComprobantesVentas
            SELECT      0, IdVenta, IdTipoComprobanteAfip, pNroComprobante, FechaGenerado
            FROM        tmp_comprobante;

            -- Actulizo el parametro empresa
            UPDATE	ParametroEmpresa
            SET		Valor = pNroComprobante + 1
            WHERE   IdEmpresa = pIdEmpresa AND Parametro = 'NUMEROCOMPROBANTE';

            UPDATE tmp_comprobante SET NroComprobante = pNroComprobante, IdComprobanteAfip = LAST_INSERT_ID();
        ELSE -- es cotizacion, presupuesto, etc.
            INSERT INTO ComprobantesVentas
            SELECT      0, IdVenta, IdTipoComprobanteAfip, NULL, FechaGenerado
            FROM        tmp_comprobante;

            UPDATE tmp_comprobante SET IdComprobanteAfip = LAST_INSERT_ID();
        END IF;
    COMMIT;

    SELECT * FROM tmp_comprobante;

    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

    DROP TEMPORARY TABLE IF EXISTS tmp_comprobante;
END$$

DELIMITER ;