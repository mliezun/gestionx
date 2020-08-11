DROP procedure IF EXISTS `xsp_inf_llenar_param_puntosventa`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_llenar_param_puntosventa`(pIdEmpresa int)
BEGIN
	/*
    Permite buscar los puntos de venta dada una cadena de búsqueda que se autocompleta con el nombre del punto de venta que coincide con parte del nombre.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    SELECT IdPuntoVenta Id, PuntoVenta Nombre FROM PuntosVenta WHERE Estado = 'A' AND IdEmpresa = pIdEmpresa
    UNION
    SELECT 0 Id, 'Todos' Nombre;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$


DELIMITER ;