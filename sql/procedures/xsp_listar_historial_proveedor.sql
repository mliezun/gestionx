DROP PROCEDURE IF EXISTS `xsp_listar_historial_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_historial_proveedor`(pIdProveedor bigint)
SALIR: BEGIN
	/*
	Permite listar el historial de descuentos de un proveedor.
	*/
    SELECT  p.Proveedor, hd.*
    FROM    Proveedores p
    INNER JOIN HistorialDescuentos hd USING(IdProveedor)
    WHERE   p.IdProveedor = pIdProveedor
    ORDER BY FechaFin;
END$$

DELIMITER ;