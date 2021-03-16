DROP procedure IF EXISTS `xsp_inf_autocompletar_param_codigo_unificado`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_autocompletar_param_codigo_unificado`(pIdEmpresa int, pCadena varchar(50))
PROC: BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT  SUBSTRING_INDEX(a.Articulo, ' ', 1) Id, SUBSTRING_INDEX(a.Articulo, ' ', 1) Nombre
    FROM    Articulos a
    WHERE   a.IdEmpresa = pIdEmpresa
            AND (
                    a.Articulo LIKE CONCAT('%', pCadena, '%') OR
                    a.Codigo LIKE CONCAT('%', pCadena, '%')
                )
            AND (a.Estado = 'A')
    GROUP BY Id;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;