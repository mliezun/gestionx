DROP procedure IF EXISTS `xsp_inf_autocompletar_param_proveedor`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_autocompletar_param_proveedor`(pIdEmpresa int, pCadena varchar(50))
PROC: BEGIN
	/*
    Permite traer el parámetro dado el Id
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT  IdProveedor Id, p.Proveedor Nombre
    FROM    Proveedores p 
    WHERE   p.IdEmpresa = pIdEmpresa
            AND p.Proveedor LIKE CONCAT('%', pCadena, '%')
            AND (p.Estado = 'A');
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;