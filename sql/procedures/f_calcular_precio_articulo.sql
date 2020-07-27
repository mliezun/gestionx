DROP function IF EXISTS `f_calcular_precio_articulo`;
DELIMITER $$
CREATE FUNCTION `f_calcular_precio_articulo`(pIdArticulo bigint, pDescuento decimal(10,4), pPorcentaje decimal(10,4)) RETURNS decimal(12,2)
    READS SQL DATA
BEGIN
	/*
    Calcula el precio de un artículo.
    */
	DECLARE pPrecioCosto, pPorcentajeIVA decimal(12,2);
    DECLARE pIdTipoIVA int;
    
	SELECT a.PrecioCosto, t.Porcentaje 
    INTO pPrecioCosto, pPorcentajeIVA
    FROM Articulos a 
    INNER JOIN TiposIVA t USING(IdTipoIVA)
    WHERE IdArticulo = pIdArticulo;
    
	RETURN pPrecioCosto * (1-pDescuento/100) * (1+pPorcentajeIVA/100) * (1+pPorcentaje/100);
END$$

DELIMITER ;