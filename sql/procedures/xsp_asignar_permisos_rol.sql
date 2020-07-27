DROP PROCEDURE IF EXISTS `xsp_asignar_permisos_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_asignar_permisos_rol`(pToken varchar(500), pIdRol tinyint, pPermisos json, 
											pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50), pMotivo varchar(75), pAutoriza varchar(25))
SALIR:BEGIN
	/*
	Dado el rol y un json formado por la lista de los permisos en pPermisos = [IdPermiso1, IdPermiso2,...,IdPermisoN], asigna los permisos seleccionados como dados y quita los no dados. 
    Los asigna siempre y cuando los permisos sean hoja. Cambia el token de los usuarios del rol así deban reiniciar sesión y retomar permisos. 
    Devuelve OK o el mensaje de error en Mensaje.
    */
    DECLARE pIndice, pIdPermiso int;
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_asignar_permisos_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS(SELECT IdRol FROM Roles WHERE IdRol = pIdRol)THEN
		SELECT 'No existe el rol.' Mensaje;
        LEAVE SALIR;
    END IF;
    -- Asigna permisos aplicando el parser de la lista (extrayendo los valores de IdPermiso)
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		DROP TEMPORARY TABLE IF EXISTS tmp_permisosrol;
        CREATE TEMPORARY TABLE tmp_permisosrol ENGINE = MEMORY AS
        SELECT * FROM PermisosRol WHERE IdRol = pIdRol;
		-- Borra
		INSERT INTO aud_PermisosRol
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion,f_aud_motivo(pMotivo, pAutoriza), 'B', PermisosRol.* FROM PermisosRol WHERE IdRol = pIdRol;
		-- Primero borra todos los permisos. Esto implica que los permisos no pasados en la lista se consideran como no dados.
        DELETE FROM PermisosRol WHERE IdRol = pIdRol;
        SET pIndice = 0;
        -- Para cada posición del elemento en la lista, inserta el permiso, siempre y cuando esté activo
        loop_1: LOOP
			SET pIdPermiso = (SELECT JSON_EXTRACT(pPermisos,CONCAT('$[',pIndice,']')));
            SET pIndice = pIndice + 1;
            IF pIdPermiso IS NULL THEN
				LEAVE loop_1;
			END IF;
            IF EXISTS(SELECT IdPermiso FROM Permisos WHERE IdPermiso = pIdPermiso AND Estado <> 'A')THEN
				SELECT 'No se puede asignar un permiso que no esté activo.' Mensaje;
                ROLLBACK;
                LEAVE SALIR;
            END IF;
			-- Asigna el permiso siempre y cuando sea hoja
            IF (SELECT f_es_hoja_permiso(pIdPermiso)) = 'S' THEN
				INSERT INTO PermisosRol VALUES(pIdPermiso, pIdRol);
			END IF;
		END LOOP loop_1;
		-- Audita
		INSERT INTO aud_PermisosRol
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, f_aud_motivo(pMotivo, pAutoriza), 'I', PermisosRol.* FROM PermisosRol WHERE IdRol = pIdRol;
        -- Cambia el token de los usuarios del rol así deban reiniciar sesión y tomar de nuevo los permisos
        IF EXISTS(SELECT IdPermiso
			FROM
			(SELECT IdPermiso
			FROM tmp_permisosrol
			UNION ALL
			SELECT IdPermiso
			FROM PermisosRol
			WHERE IdRol = pIdRol) p
			GROUP BY IdPermiso
			HAVING COUNT(IdPermiso) = 1) THEN
				-- Antes
				INSERT INTO aud_Usuarios
				SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, f_aud_motivo(pMotivo, pAutoriza), 'A', Usuarios.* FROM Usuarios WHERE IdRol = pIdRol;
				-- Cambia token usuarios
				UPDATE Usuarios SET Token = md5(CONCAT(CONVERT(IdUsuario,char(10)),UNIX_TIMESTAMP())) WHERE IdRol = pIdRol;
				-- Después
				INSERT INTO aud_Usuarios
				SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, f_aud_motivo(pMotivo, pAutoriza), 'D', Usuarios.* FROM Usuarios WHERE IdRol = pIdRol;
		END IF;
        
        SELECT 'OK' Mensaje;
 
		DROP TEMPORARY TABLE IF EXISTS tmp_permisosrol;
	COMMIT;
END$$

DELIMITER ;