DROP procedure IF EXISTS `xsp_inf_autocompletar_param_vendedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_autocompletar_param_vendedor`(pIdEmpresa int, pCadena varchar(50))
PROC: BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT  IdUsuario Id, CONCAT(u.Apellidos, ', ', u.Nombres) Nombre
    FROM    Usuarios u 
    WHERE   u.IdEmpresa = pIdEmpresa
            AND (
                u.Nombres LIKE CONCAT('%', pCadena, '%') OR
                u.Apellidos LIKE CONCAT('%', pCadena, '%') OR 
                CONCAT(u.Apellidos, ', ', u.Nombres) LIKE CONCAT('%', pCadena, '%')
            )
            AND (u.Estado = 'A');
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;