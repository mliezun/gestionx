DROP PROCEDURE IF EXISTS `xsp_dame_puntoventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_puntoventa`(pIdPuntoVenta bigint)
BEGIN
	/**
    * Procedimiento que sirve para instanciar un punto venta desde la base de datos.
    */
	SELECT	*
    FROM	PuntosVenta
    WHERE	IdPuntoVenta = pIdPuntoVenta;
END$$

DELIMITER ;