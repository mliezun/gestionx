DROP FUNCTION IF EXISTS `f_estado_permiso`;
DELIMITER $$
CREATE FUNCTION `f_estado_permiso`(pIdPermiso int, pIdRol int) RETURNS char(1) CHARSET utf8 READS SQL DATA 
BEGIN
	/*
    Indica si el rol tiene permiso sobre el objeto.
    Si es hoja, puede tener permiso = 'S', o no = 'N'. Si no es hoja devuelve 'G'.
    */
	IF f_es_hoja_permiso(pIdPermiso) = 'S' THEN
		IF EXISTS(SELECT IdPermiso FROM PermisosRol WHERE IdPermiso = pIdPermiso AND IdRol = pIdRol) THEN
			RETURN 'S';
		ELSE
			RETURN 'N';
		END IF;
	ELSE
		RETURN 'G';
	END IF;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS `f_es_hoja_permiso`;
DELIMITER $$
CREATE FUNCTION `f_es_hoja_permiso`(pIdPermiso int) RETURNS char(1) CHARSET utf8 READS SQL DATA 
BEGIN
	/*
    Indica si el permiso es hoja (de último nivel = 'S') o bien agrupo otros permisos (nodo = 'N')
    */
	IF EXISTS(SELECT IdPermisoPadre FROM Permisos WHERE IdPermisoPadre = pIdPermiso) THEN
		RETURN 'N';
	ELSE
		RETURN 'S';
	END IF;
END$$
DELIMITER ;

DROP function IF EXISTS `f_aud_motivo`;
DELIMITER $$
CREATE FUNCTION `f_aud_motivo`(pMotivo varchar(100), pAutoriza varchar(100)) RETURNS varchar(100) CHARSET latin1
    DETERMINISTIC
BEGIN
-- Permite auditar el motivo
RETURN concat(pMotivo, '#', pAutoriza);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_alta_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_rol`(pToken varchar(500), pHost varchar(255), pRol varchar(30), pObservaciones text, 
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Rol controlando que el nombre del rol no exista ya dentro de la misma empresa.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdRol tinyint;
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pIdEmpresa int;
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pHost IS NULL OR pHost = '') THEN
        SELECT 'Debe ingresar el url de la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pRol IS NULL OR pRol = '') THEN
        SELECT 'Debe ingresar el nombre del rol.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.URL = pHost) THEN
		SELECT 'Debe existir una empresa con el URL dado.' Mensaje;
		LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas E WHERE E.URL = pHost);
    IF EXISTS(SELECT Rol FROM Roles WHERE Rol = pRol AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre del rol ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO Roles SELECT 0, pRol, 'A', pObservaciones, pIdEmpresa;
		SET pIdRol = LAST_INSERT_ID();
		-- Audita
		INSERT INTO aud_Roles
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', Roles.* FROM Roles WHERE IdRol = pIdRol;
        
        SELECT CONCAT('OK', pIdRol) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_activar_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_rol`(pToken varchar(500), pIdRol tinyint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del Rol a Activo siempre y cuando no esté activo ya. Devuelve OK o el mensaje de error en Mensaje.
    */
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Roles WHERE IdRol = pIdRol AND Estado = 'A') THEN
		SELECT 'El rol ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Roles
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A', Roles.* FROM Roles WHERE IdRol = pIdRol;
		-- Activa Rol
		UPDATE Roles SET Estado = 'A' WHERE IdRol = pIdRol;
		-- Después
		INSERT INTO aud_Roles
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D', Roles.* FROM Roles WHERE IdRol = pIdRol;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_puede_ejecutar`;
DELIMITER $$
CREATE PROCEDURE `xsp_puede_ejecutar`(pJWT varchar(500), pProcedimiento varchar(100),
										OUT pMensaje varchar(255), OUT pIdUsuario bigint)
BEGIN
	/*
    Permite determinar si el usuario logueado puede ejecutar un procedimiento.
    Retorna OK o el mensaje de error en pMensaje y el id del usuario en pIdUsuario.
    */
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    SELECT 		COALESCE(IdUsuario, 0)
    INTO		pIdUsuario
    FROM		Usuarios u
    INNER JOIN	Empresas e USING(IdEmpresa)
    INNER JOIN	ModulosEmpresas me USING(IdEmpresa)
    INNER JOIN	Permisos p USING(IdModulo)
	INNER JOIN	Roles r USING(IdRol)
    INNER JOIN	PermisosRol USING(IdPermiso, IdRol)
    WHERE		u.Token = pJWT AND u.Estado = 'A'
				AND p.Procedimiento = pProcedimiento
	LIMIT		1;
                
	IF pIdUsuario IS NULL OR pIdUsuario = 0 THEN
		SET pMensaje = 'Usted no posee los permisos para realizar esta acción.';
	ELSEIF EXISTS (SELECT IdEmpresa FROM Empresas e INNER JOIN Usuarios u USING(IdEmpresa) WHERE e.Estado != 'A' AND u.IdUsuario = pIdUsuario) THEN
		SET pMensaje = 'Usted no puede ingresar, su empresa no está habilitada.';
    ELSE
		SET pMensaje = 'OK';
    END IF;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_borra_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_rol`(pToken varchar(500), pIdRol tinyint, pObservaciones text,
								pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite borrar un Rol existente y sus permisos asociados controlando que no existan usuarios asociados.
    Devuelve OK o el mensaje de error en Mensaje.
    */
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdRol FROM Usuarios WHERE IdRol = pIdRol) THEN
		SELECT 'No se puede borrar el rol. Existen usuarios asociados.' Mensaje;
		LEAVE SALIR;
	END IF;
	-- Borra el rol y sus Permisos
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Audita
		INSERT INTO aud_PermisosRol
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ROLBORRA', 'B', PermisosRol.* FROM PermisosRol WHERE IdRol = pIdRol;
        -- Borra permisos
        DELETE FROM PermisosRol WHERE IdRol = pIdRol;
		-- Audito
		INSERT INTO aud_Roles
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'B', Roles.* FROM Roles WHERE IdRol = pIdRol;
        -- Borra rol
        DELETE FROM Roles WHERE IdRol = pIdRol;
        
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_buscar_roles`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_roles`(pHost varchar(255), pCadena varchar(30), pEstado char(1))
BEGIN
	/*
    Permite buscar los roles dada una cadena de búsqueda y la opción si incluye o no los dados de baja [S|N] respectivamente.
    Para listar todos, cadena vacía.
    */
    SELECT		r.*
    FROM		Roles r
    INNER JOIN	Empresas e USING(IdEmpresa)
    WHERE		e.URL = pHost
				AND r.Rol LIKE CONCAT('%', pCadena, '%')
                AND (r.Estado = pEstado OR pEstado = 'T');
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_dame_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_rol`(pIdRol tinyint)
BEGIN
	/*
    Procedimiento que sirve para instanciar un rol desde la base de datos.
    */
	SELECT	*
    FROM	Roles
    WHERE	IdRol = pIdRol;
END$$
DELIMITER ;

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

DROP PROCEDURE IF EXISTS `xsp_darbaja_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_rol`(pToken varchar(500), pIdRol tinyint, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    Permite cambiar el estado del Rol a Baja siempre y cuando no esté dado de baja y no existan usuarios activos asociados. Devuelve OK o el mensaje de error en Mensaje.
    */
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
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM Roles WHERE IdRol = pIdRol AND Estado = 'B') THEN
		SELECT 'El rol ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF EXISTS(SELECT IdUsuario FROM Usuarios WHERE IdRol = pIdRol AND Estado = 'A') THEN
		SELECT 'No se puede dar de baja el rol. Existen usuarios activos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_Roles
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','A',Roles.* FROM Roles WHERE IdRol = pIdRol;
		-- Da de baja
		UPDATE Roles SET Estado = 'B' WHERE IdRol = pIdRol;
		-- Después
		INSERT INTO aud_Roles
		SELECT 0,NOW(),CONCAT(pIdUsuario,'@',pUsuario),pIP,pUserAgent,pAplicacion,'DARBAJA','D',Roles.* FROM Roles WHERE IdRol = pIdRol;
        
		SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_rol`(pToken varchar(500), pHost varchar(255), pIdRol tinyint,
pRol varchar(30), pObservaciones text, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	Permite modificar un Rol existente controlando que el nombre del rol no exista ya.
	Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	DECLARE pIdEmpresa int;
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pHost IS NULL OR pHost = '') THEN
        SELECT 'Debe ingresar el url de la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pRol IS NULL OR pRol = '') THEN
        SELECT 'Debe ingresar el nombre del rol.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
	IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.URL = pHost) THEN
		SELECT 'Debe existir una empresa con el URL dado.' Mensaje;
		LEAVE SALIR;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Empresas E WHERE E.URL = pHost);
    IF EXISTS(SELECT Rol FROM Roles WHERE IdRol != pIdRol AND Rol = pRol AND IdEmpresa=pIdEmpresa) THEN
		SELECT 'El nombre del rol ya existe.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_Roles
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', Roles.*
        FROM Roles WHERE IdRol = pIdRol;
        -- Modifica
        UPDATE Roles 
		SET		Rol=pRol
		WHERE	IdRol=pIdRol;
		-- Despues
        INSERT INTO aud_Roles
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', Roles.*
        FROM Roles WHERE IdRol = pIdRol;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_listar_permisos_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_listar_permisos_rol`(pIdRol int)
BEGIN
	/*
	Lista todos los permisos existentes, adjuntándoles un campo estado cuyo valor es [S|N|G], S: tiene permiso, N: no tiene permiso, 
    G: agrupa permisos. Adjunta otro campo si dice si es o no permiso hoja (EsHoja = [S|N]).
    Los permisos están listados en orden jerárquico y arbóreo, con el nodo padre, el nivel del árbol y una cadena para mostrarlo ordenado.
    */
	DECLARE pNivel tinyint DEFAULT 0;
	DECLARE pIdEmpresa int;

	SET pIdEmpresa = (SELECT IdEmpresa FROM Roles WHERE IdRol = pIdRol);
    
    DROP TEMPORARY TABLE IF EXISTS tmp_permisos, Arbol, aux;

	CREATE TEMPORARY TABLE tmp_permisos
		SELECT 	p.*
		FROM	Permisos p
		INNER JOIN ModulosEmpresas me USING(IdModulo)
		WHERE 	me.IdEmpresa = pIdEmpresa;
    
    -- Tabla auxiliar para ir armando árbol
    CREATE TEMPORARY TABLE Arbol ENGINE = MEMORY
		SELECT	p.IdPermiso, IdPermisoPadre, Permiso, Descripcion, Orden, f_es_hoja_permiso(p.IdPermiso) EsHoja, Procedimiento,
				CASE WHEN pr.IdRol IS NULL THEN 'N' ELSE 'S' END 'Estado', Observaciones, 0 'Nivel', 'N' Visitado, '00000000000000000000' Ordenar
		FROM	tmp_permisos p LEFT JOIN (select * from PermisosRol where IdRol = pIdRol) pr ON p.IdPermiso = pr.IdPermiso
		WHERE	p.Estado='A';
    -- Nivel 1
    SET pNivel = 1;
    UPDATE	Arbol SET Visitado = 'S', Nivel = pNivel, Ordenar = LPAD(CONVERT(Orden, char(3)), 2,'0'), Estado=f_estado_permiso(IdPermiso, pIdRol)
    WHERE	IdPermisoPadre IS NULL;
    -- Loop hasta visitar todos los nodos
    armar_arbol: LOOP
        IF NOT EXISTS(SELECT Visitado FROM Arbol WHERE Visitado='N') THEN
			LEAVE armar_arbol;
		END IF;
        -- Tabla auxiliar de los padres ya visitados
        CREATE TEMPORARY TABLE aux ENGINE = MEMORY
			SELECT IdPermiso, Nivel, Ordenar FROM Arbol WHERE Nivel = pNivel AND Visitado='S';
		UPDATE	Arbol
				INNER JOIN aux ON Arbol.IdPermisoPadre = aux.IdPermiso
		SET		Arbol.Visitado = 'S', Arbol.Nivel = pNivel + 1, Arbol.Ordenar = CONCAT(aux.Ordenar, '.', LPAD(CONVERT(Arbol.Orden, char(3)), 2,'0')),
				Estado=f_estado_permiso(Arbol.IdPermiso, pIdRol);
        DROP TEMPORARY TABLE aux;
		SET pNivel = pNivel + 1;
    END LOOP armar_arbol;
    SELECT	IdPermiso, IdPermisoPadre, Permiso, Descripcion, EsHoja, Estado, Nivel, Ordenar, Procedimiento, Observaciones FROM Arbol ORDER BY Ordenar;
    
    DROP TEMPORARY TABLE IF EXISTS tmp_permisos, Arbol, aux;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_clonar_rol`;
DELIMITER $$
CREATE PROCEDURE `xsp_clonar_rol`(pJWT varchar(500), pIdRol tinyint, pRol varchar(30),
											pIP varchar(40), pUserAgent varchar(255), pApp varchar(50))
PROC: BEGIN
	/*
    Permite clonar un rol a partir de un existente, pasándole el nombre, controlando que no exista ya. 
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pIdRolNuevo tinyint;
    DECLARE pRolNuevo varchar(30);
    DECLARE pIdUsuario bigint;
	DECLARE pIdEmpresa int;
	DECLARE pUsuario varchar(120);
	DECLARE pMensaje varchar(255);
    -- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros.
	CALL xsp_puede_ejecutar(pJWT, 'xsp_clonar_rol', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE PROC;
	END IF;
    IF (pRol IS NULL OR pRol = '') THEN
        SELECT 'Debe ingresar el nombre del rol.' Mensaje;
        LEAVE PROC;
	END IF;
	SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	IF EXISTS(SELECT Rol FROM Roles WHERE Rol = pRol AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'El nombre del rol ya existe.' Mensaje;
		LEAVE PROC;
	END IF;
	-- Da de alta calculando el próximo id y clonando también la tabla permisos
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        SET pRolNuevo = (SELECT CONCAT(Rol, ' (', IdRol, ')') FROM Roles WHERE IdRol = pIdRol);
        INSERT INTO Roles SELECT 0, pRol, 'A', CONCAT('Clonado de ', pRolNuevo), pIdEmpresa;
		SET pIdRolNuevo = LAST_INSERT_ID();
		-- Audito
		INSERT INTO aud_Roles
		SELECT 0, NOW(), pUsuario, pIP, pUserAgent, pApp, NULL, 'I', Roles.* FROM Roles 
        WHERE IdRol = pIdRolNuevo;
        INSERT INTO PermisosRol
			SELECT	IdPermiso, pIdRolNuevo
            FROM	PermisosRol
            WHERE	IdRol = pIdRol;
		-- Audito
		INSERT INTO aud_PermisosRol
		SELECT 0, NOW(), pUsuario, pIP, pUserAgent, pApp, NULL, 'I', PermisosRol.* FROM PermisosRol
        WHERE IdRol = pIdRolNuevo;
        SELECT CONCAT('OK', pIdRolNuevo) Mensaje;
	COMMIT;
END$$
DELIMITER ;