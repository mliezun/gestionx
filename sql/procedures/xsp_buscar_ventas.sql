DROP PROCEDURE IF EXISTS `xsp_buscar_ventas`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_ventas`(pIdPuntoVenta bigint, pIdEmpresa int, pFechaDesde datetime,
pFechaHasta datetime, pIdCliente bigint, pTipo char(1), pIncluyeBajas char(1))
BEGIN
	/*
    * Permite buscar las ventas de un punto de venta, dado el tipo de venta (T para listar todas),
    * un cliente (0 para listar todos) y un rango de fechas (rango de fechas nulo, para listar todas).
    */
    IF (pFechaDesde IS NULL) THEN
        SET pFechaDesde = '1990-01-01 00:00:00';
	END IF;
    IF (pFechaHasta IS NULL) THEN
        SET pFechaHasta = NOW();
	END IF;
    SELECT	v.*, u.Usuario, (IF(c.Tipo = 'F',CONCAT(c.Apellidos,', ',c.Nombres),c.RazonSocial)) Cliente, tca.TipoComprobanteAfip, tt.TipoTributo,
            c.Observaciones ObservacionesCliente, c.Datos->>'$.Email' EmailCliente, ca.Canal
    FROM	Ventas v
    INNER JOIN Clientes c USING (IdCliente)
    INNER JOIN Canales ca USING (IdCanal)
    INNER JOIN Usuarios u USING (IdUsuario)
    LEFT JOIN TiposComprobantesAfip tca USING(IdTipoComprobanteAfip)
    LEFT JOIN TiposTributos tt USING(IdTipoTributo)
    WHERE	v.IdEmpresa = pIdEmpresa
            AND v.IdPuntoVenta = pIdPuntoVenta
            AND (v.IdCliente = pIdCliente OR pIdCliente = 0)
            AND (v.Tipo = pTipo OR pTipo = 'T')
            AND (v.Estado != 'B' OR pIncluyeBajas = 'S')
            AND (v.FechaAlta BETWEEN pFechaDesde AND pFechaHasta)
    ORDER BY v.FechaAlta DESC, v.Estado;
END$$

DELIMITER ;