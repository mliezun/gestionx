DROP PROCEDURE IF EXISTS `xsp_dame_venta`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_venta`(pIdVenta bigint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar una venta desde la base de datos.
    */
	SELECT	v.*, COALESCE(SUM(p.Monto),0) MontoPagado, tca.TipoComprobanteAfip, tt.TipoTributo
    FROM	Ventas v
    LEFT JOIN TiposComprobantesAfip tca USING(IdTipoComprobanteAfip)
    LEFT JOIN TiposTributos tt USING(IdTipoTributo)
            LEFT JOIN Pagos p ON p.Codigo = v.IdVenta AND p.Tipo = 'V'
    WHERE	IdVenta = pIdVenta;
END$$

DELIMITER ;