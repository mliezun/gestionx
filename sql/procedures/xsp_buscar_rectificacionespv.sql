DROP PROCEDURE IF EXISTS `xsp_buscar_rectificacionespv`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_rectificacionespv`(pIdEmpresa int, pIdPuntoVenta bigint, pIdCanal bigint, pCadena varchar(100), pIncluyeBajas char(1))
SALIR: BEGIN
	/*
	Permite buscar rectificaciones dentro de un punto de venta de una empresa, indicando una cadena de búsqueda
    y si se incluyen bajas. Si pIdPuntoVenta = 0 lista todas las rectficaciones activos de una empresa.
	*/
    SELECT  r.*, a.Articulo, a.Codigo, pr.Proveedor, po.PuntoVenta PuntoVentaOrigen, pd.PuntoVenta PuntoVentaDestino, c.Canal
    FROM    RectificacionesPV r
	INNER JOIN Articulos a USING(IdArticulo)
	INNER JOIN Proveedores pr USING(IdProveedor)
	INNER JOIN Canales c USING(IdCanal)
    INNER JOIN PuntosVenta po ON r.IdPuntoVentaOrigen = po.IdPuntoVenta
    INNER JOIN PuntosVenta pd ON r.IdPuntoVentaDestino = pd.IdPuntoVenta
    WHERE   r.IdEmpresa = pIdEmpresa
			AND (r.IdCanal = pIdCanal OR pIdCanal = 0)
			AND (pIdPuntoVenta = r.IdPuntoVentaDestino OR pIdPuntoVenta = r.IdPuntoVentaOrigen OR pIdPuntoVenta = 0)
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%')
                )
            AND (pIncluyeBajas = 'S' OR r.Estado = 'P')
    GROUP BY r.IdRectificacionPV
	ORDER BY r.Estado;
END$$

DELIMITER ;