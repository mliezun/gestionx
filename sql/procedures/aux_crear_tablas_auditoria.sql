DROP PROCEDURE IF EXISTS `aux_crear_tablas_auditoria`;
DELIMITER $$
CREATE PROCEDURE `aux_crear_tablas_auditoria`(pSchema varchar(100))
SALIR: BEGIN
	/*
    Procedimiento que permite crear todas las tablas de auditoría de la base de datos indicada en pSchema.
    */
    DECLARE pIndice int;
    DECLARE pTabla varchar(100);
    DECLARE pStmtAtributosTabla, pStmt text;
    
   	DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
		-- SHOW ERRORS;
		SELECT IF(pTabla IS NULL, 'No se pudo leer las tablas', CONCAT('Error al crear tabla de auditoría: aud_',pTabla)) Mensaje;
        ROLLBACK;
	END;
    -- Obtener nombres de todas las tablas excepto aquellas que son de auditoría
    DROP TEMPORARY TABLE IF EXISTS tmp_table_names;
    SET @rowNum = 0;
    CREATE TEMPORARY TABLE tmp_table_names ENGINE = MEMORY
		SELECT 	(@rowNum := @rowNum + 1) Fila, TABLE_NAME Tabla
        FROM 	`INFORMATION_SCHEMA`.`TABLES` 
        WHERE 	`TABLE_SCHEMA` = pSchema AND 
				TABLE_NAME NOT LIKE 'aud_%' ;
	
    START TRANSACTION;
    SET pIndice = 1;
    WHILE (pIndice <= @rowNum) DO
		SET pTabla = (SELECT Tabla FROM tmp_table_names WHERE Fila = pIndice);
		
        DROP TEMPORARY TABLE IF EXISTS tmp_atributos_tabla;
        CREATE TEMPORARY TABLE tmp_atributos_tabla ENGINE = MEMORY
			SELECT 	CAST(COLUMN_NAME AS CHAR(100)) AS `Field`, CAST(COLUMN_TYPE AS CHAR(100)) AS `Type`,
					CAST(IS_NULLABLE AS CHAR(100)) AS `Null`, CAST(COLUMN_KEY AS CHAR(100)) AS `Key`,
                    CAST(COLUMN_DEFAULT AS CHAR(100)) AS `Default`
			FROM 	`INFORMATION_SCHEMA`.`COLUMNS`
			WHERE 	`TABLE_SCHEMA` = pSchema AND 
					`TABLE_NAME` = pTabla
			ORDER BY ORDINAL_POSITION;
		
		SET pStmtAtributosTabla = (	SELECT 	GROUP_CONCAT(' `', Field, '` ' , Type, ' ', 
                                                IF(`Null` = 'NO', 'NOT NULL', 'DEFAULT NULL'))
									FROM 	tmp_atributos_tabla);        
        
        call xsp_eval(CONCAT('DROP TABLE IF EXISTS `aud_', pTabla, '`;'));
        SET pStmt = CONCAT('CREATE TABLE `aud_', pTabla,'` (
			`Id` bigint(20) NOT NULL AUTO_INCREMENT,
			`FechaAud` datetime NOT NULL,
			`UsuarioAud` varchar(30) NOT NULL,
			`IPAud` varchar(40) NOT NULL,
			`UserAgentAud` varchar(255) DEFAULT NULL,
			`AplicacionAud` varchar(50) NOT NULL,
			`MotivoAud` varchar(100) DEFAULT NULL,
			`TipoAud` char(1) NOT NULL,', pStmtAtributosTabla, ',
			PRIMARY KEY (`Id`),
			KEY `IX_FechaAud` (`FechaAud`),
			KEY `IX_Usuario` (`UsuarioAud`),
			KEY `IX_IP` (`IPAud`),
			KEY `IX_Aplicacion` (`AplicacionAud`)
		) ENGINE=InnoDB;');
        
        CALL xsp_eval(pStmt);
        DROP TEMPORARY TABLE IF EXISTS tmp_atributos_tabla;
		SET pIndice = pIndice + 1;
    END WHILE;
    COMMIT;
     
    DROP TEMPORARY TABLE IF EXISTS tmp_table_names;
	SELECT 'OK';
END $$

DELIMITER ;
