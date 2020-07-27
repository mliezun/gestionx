DROP function IF EXISTS `f_existencias_articulo`;
DELIMITER $$
CREATE FUNCTION `f_existencias_articulo`(pIdArticulo bigint) RETURNS json
    READS SQL DATA
BEGIN
	/*
    Calcula el precio de un artículo.
    */
    DECLARE pExistencias json;

	SELECT      JSON_ARRAYAGG(JSON_OBJECT(
                    'PuntoVenta', pv.PuntoVenta,
                    'Cantidad', ec.Cantidad,
                    'Canal', cc.Canal
                ))
    INTO        pExistencias
    FROM        ExistenciasConsolidadas ec
    INNER JOIN  PuntosVenta pv USING(IdPuntoVenta)
    INNER JOIN  Canales cc USING(IdCanal)
    WHERE       ec.IdArticulo = pIdArticulo AND pv.Estado = 'A' AND cc.Estado = 'A'
    GROUP BY    IdArticulo;
    
	RETURN pExistencias;
END$$

DELIMITER ;