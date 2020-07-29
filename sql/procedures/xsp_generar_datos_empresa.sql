DROP PROCEDURE IF EXISTS `xsp_generar_datos_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_generar_datos_empresa`(pIdEmpresa int, out pMensaje varchar(255))
BEGIN
	/*
    Permite generar los roles y parámetros de una empresa, a partir de sus módulos y los roles genéricos.
    */
    DECLARE pIndice int default 1;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- show errors;
		SET pMensaje = 'Error en la transacción interna. Contáctese con el administrador.';
	END;

    SET pMensaje = NULL;
    
    SET @fila = 0;
    DROP TEMPORARY TABLE IF EXISTS tmp_parametros_empresa;
    CREATE TEMPORARY TABLE tmp_parametros_empresa ENGINE = MEMORY
		SELECT		@fila := @fila + 1 Fila, p.Parametro, p.IdModulo, p.DameValor
        FROM		Parametros p
        INNER JOIN	ModulosEmpresas me USING (IdModulo)
        WHERE		me.IdEmpresa = pIdEmpresa;

        
	-- DameValor recibe @pIdEmpresa y retorna el valor en @pValor
	SET @pIdEmpresa = pIdEmpresa;
    
	WHILE pIndice <= @fila DO
        call xsp_eval((SELECT DameValor FROM tmp_parametros_empresa WHERE Fila = pIndice));
        
		UPDATE	tmp_parametros_empresa
        SET		DameValor = @pValor
        WHERE	Fila = pIndice;
        
        SET pIndice = pIndice + 1;
    END WHILE;

    DROP TEMPORARY TABLE IF EXISTS tmp_roles_permisosrol_genericos;
    CREATE TEMPORARY TABLE tmp_roles_permisosrol_genericos ENGINE = MEMORY
        SELECT			rg.IdRolGenerico, rg.Rol, rg.Estado, rg.Observaciones, prg.IdPermiso
        FROM			ModulosEmpresas me
        INNER JOIN		Permisos p USING(IdModulo)
        INNER JOIN		PermisosRolGenerico prg USING(IdPermiso)
        INNER JOIN		RolesGenericos rg USING(IdRolGenerico)
        WHERE			me.IdEmpresa = pIdEmpresa;

    INSERT INTO Roles
    SELECT      0, Rol, Estado, Observaciones, pIdEmpresa
    FROM        tmp_roles_permisosrol_genericos
    GROUP BY    IdRolGenerico, Rol, Estado, Observaciones;

    DROP TEMPORARY TABLE IF EXISTS tmp_permisosrol;
    CREATE TEMPORARY TABLE tmp_permisosrol ENGINE = MEMORY
        SELECT  DISTINCT Rol, IdPermiso
        FROM    tmp_roles_permisosrol_genericos;

    INSERT INTO		PermisosRol
    SELECT			IdPermiso, (SELECT IdRol FROM Roles WHERE IdEmpresa = pIdEmpresa AND Rol = (SELECT Rol FROM tmp_permisosrol WHERE IdPermiso=t.IdPermiso LIMIT 1))
    FROM            tmp_roles_permisosrol_genericos t
    GROUP BY        IdPermiso;

    INSERT INTO		ParametroEmpresa
    SELECT			t.Parametro, pIdEmpresa, t.IdModulo, t.DameValor
    FROM			tmp_parametros_empresa t;

    INSERT INTO Usuarios VALUES (0, (SELECT MIN(IdRol) FROM Roles WHERE IdEmpresa = pIdEmpresa), 'Admin', 'Admin', 'admin', md5('admin'), '', CONCAT('admin@example.com'), '0', NOW(), NOW(), 'N', 'A', NULL, pIdEmpresa);

    SET pMensaje = 'OK';
    
    DROP TEMPORARY TABLE IF EXISTS tmp_parametros_empresa;
    DROP TEMPORARY TABLE IF EXISTS tmp_roles_permisosrol_genericos;
    DROP TEMPORARY TABLE IF EXISTS tmp_permisosrol;
END$$
DELIMITER ;
