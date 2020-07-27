DROP PROCEDURE IF EXISTS `xsp_dame_remito`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_remito`(pIdRemito bigint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un remito desde la base de datos.
    */
	SELECT		r.*, i.IdIngreso, p.Proveedor, c.Canal
    FROM		Remitos r
	INNER JOIN	Ingresos i USING(IdRemito)
	INNER JOIN	Proveedores p USING(IdProveedor)
	INNER JOIN	Canales c USING(IdCanal)
    WHERE	r.IdRemito = pIdRemito;
END$$

DELIMITER ;