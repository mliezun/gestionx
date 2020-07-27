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