DROP PROCEDURE IF EXISTS `xsp_buscar_listas_precio`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_listas_precio`(pIdEmpresa int, pCadena varchar(100), pIncluyeBajas char(1), pIncluyeDefecto char(1))
SALIR: BEGIN
	/*
	Permite buscar listas de precios dentro de una empresa, indicando una cadena de búsqueda
    y si se incluyen bajas.
	*/
    SELECT  lp.*
    FROM    ListasPrecio lp
    WHERE   lp.IdEmpresa = pIdEmpresa
            AND (
                    lp.Lista LIKE CONCAT('%', pCadena, '%')
                )
            AND (pIncluyeBajas = 'S' OR lp.Estado = 'A')
            AND (pIncluyeDefecto = 'S' OR lp.Lista != 'Por Defecto');
END$$

DELIMITER ;