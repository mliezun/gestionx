DROP procedure IF EXISTS `xsp_inf_autocompletar_param_articulo`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_autocompletar_param_articulo`(pIdEmpresa int, pCadena varchar(50))
PROC: BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT  IdArticulo Id, CONCAT(a.Articulo, ' (', a.Codigo, ') [', p.Proveedor, ']') Nombre
    FROM    Articulos a
    INNER JOIN  Proveedores p USING(IdProveedor)
    WHERE   a.IdEmpresa = pIdEmpresa
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%') OR
                    a.Codigo LIKE CONCAT('%', pCadena, '%') OR
                    p.Proveedor LIKE CONCAT('%', pCadena, '%')
                )
            AND (a.Estado = 'A');
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;