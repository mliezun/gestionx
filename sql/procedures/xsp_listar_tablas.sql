DROP PROCEDURE IF EXISTS `xsp_listar_tablas`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_tablas`(pSchema varchar(255))
SALIR: BEGIN
    /*
	Permite listar las tablas del sistema.
	*/    
    -- Obtener nombres de todas las tablas excepto aquellas que son de auditoría
    DROP TEMPORARY TABLE IF EXISTS tmp_atributos_tabla;
    CREATE TEMPORARY TABLE tmp_atributos_tabla ENGINE = MEMORY
        SELECT 	c.`TABLE_NAME` Tabla, JSON_ARRAYAGG(JSON_OBJECT(
                    'Columna', CAST(COLUMN_NAME AS CHAR(255)),
                    'Tipo', CAST(COLUMN_TYPE AS CHAR(255)),
                    'Null', CAST(IS_NULLABLE AS CHAR(255)),
                    'Key', CAST(COLUMN_KEY AS CHAR(255)),
                    'Default', CAST(COLUMN_DEFAULT AS CHAR(255))
                )) Columnas
        FROM 	`INFORMATION_SCHEMA`.`COLUMNS` c
        WHERE 	`TABLE_SCHEMA` = pSchema
        GROUP BY c.`TABLE_NAME`;

    SELECT  JSON_ARRAYAGG(JSON_OBJECT(
            'Tabla', t.Tabla,
            'Columnas', t.Columnas
            )) Tablas
    FROM    tmp_atributos_tabla t;

    DROP TEMPORARY TABLE IF EXISTS tmp_atributos_tabla;
END$$

DELIMITER ;