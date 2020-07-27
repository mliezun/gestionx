DROP PROCEDURE IF EXISTS `xsp_listar_planes`;

DELIMITER $$
CREATE PROCEDURE `xsp_listar_planes`(pEstado CHAR(1))
BEGIN
    /*
    Devuelve listado de los planes, filtrando por estado.
    */
    SELECT IdPlan, Plan, CantDias, Precio, Descripcion, Estado
    FROM Planes
    WHERE Estado = pEstado;

END $$

DELIMITER ;