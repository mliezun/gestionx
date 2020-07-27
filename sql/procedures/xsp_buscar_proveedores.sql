DROP PROCEDURE IF EXISTS `xsp_buscar_proveedores`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_proveedores`(pIdEmpresa int, pCadena varchar(100), pIncluyeBajas char(1))
SALIR: BEGIN
	/*
	Permite buscar proveedores dentro de una empresa indicando una cadena de búsqueda y
    si se incluyen bajas.
	*/
    SELECT  p.*, - cc.Monto Deuda
    FROM    Proveedores p
    INNER JOIN CuentasCorrientes cc ON cc.IdEntidad = p.IdProveedor AND cc.Tipo = 'P'
    WHERE   p.IdEmpresa = pIdEmpresa AND p.Proveedor LIKE CONCAT('%', pCadena, '%')
            AND (pIncluyeBajas = 'S' OR p.Estado = 'A');
END$$

DELIMITER ;