/*
-- Ideas --
    - Tablas a ocultar
    - Columnas a ocultar
    - Transformaciones a nombres de tablas
    - Transformaciones a nombres de columnas
    - Columnas incruzables (Estado, Observaciones, IdEmpresa, ...)
Al seleccionar una tabla en la interfaz de creación de informes se grisan todas las que no se pueden
cruzar por alguna columna.
Después de elegir las tablas se eligen las columnas de cada una que se desean incluir en los informes.
Luego se eligen cuáles son los atributos que se van a incluir en el where (es decir los que funcionarán como filtros).
Por último se genera el procedimiento almacenado y se inserta en la tabla informes.
*/



DROP procedure IF EXISTS `xsp_inf_dame_modeloreporte`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_dame_modeloreporte`(pIdEmpresa int, pIdModeloReporte int)
BEGIN
	/*
    Trae todos los campos de la tabla ModelosReporte.
    */
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT		*
    FROM		ModelosReporte
    WHERE		IdModeloreporte = pIdModeloReporte;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;