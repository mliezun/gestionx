DROP procedure IF EXISTS `xsp_inf_listar_menu_reportes`;
DELIMITER $$
CREATE PROCEDURE `xsp_inf_listar_menu_reportes`(pIdEmpresa int)
BEGIN
	/*
    Lista el menú correspondiente a los informes activos, adjuntando un campo que dice si es o no es hoja (EsHoja = [S|N], cuando no es hoja es un menú de distribución).
    Los ítems de menú están listados en orden jerárquico y arbóreo, con el nodo padre, el nivel del árbol y una cadena para mostrarlo ordenado.
    */
	DECLARE pNivel tinyint DEFAULT 0;
    
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    DROP TEMPORARY TABLE IF EXISTS Arbol, aux;
    -- Tabla auxiliar para ir armando árbol
    CREATE TEMPORARY TABLE Arbol ENGINE = MEMORY AS
		SELECT	IdModeloReporte, IdModeloReportePadre, Reporte, NombreMenu, Ayuda, OrdenMenu, IF(Procedimiento IS NULL,'N','S') EsHoja, 0 'Nivel', 'N' Visitado, '00000000000000000000' Ordenar
		FROM	ModelosReporte
		WHERE	Estado='A';
    -- Nivel 1
    SET pNivel = 1;
    UPDATE	Arbol SET Visitado = 'S', Nivel = pNivel, Ordenar = LPAD(CONVERT(OrdenMenu, char(3)), 2,'0')
    WHERE	IdModeloReportePadre IS NULL;
    -- Loop hasta visitar todos los nodos
    armar_arbol: LOOP
        IF NOT EXISTS(SELECT Visitado FROM Arbol WHERE Visitado='N') THEN
			LEAVE armar_arbol;
		END IF;
        -- Tabla auxiliar de los padres ya visitados
        CREATE TEMPORARY TABLE aux ENGINE = MEMORY AS
			SELECT IdModeloReporte, Nivel, Ordenar FROM Arbol WHERE Nivel = pNivel AND Visitado='S';
		UPDATE	Arbol
				INNER JOIN aux ON Arbol.IdModeloReportePadre = aux.IdModeloReporte
		SET		Arbol.Visitado = 'S', Arbol.Nivel = pNivel + 1, Arbol.Ordenar = CONCAT(aux.Ordenar, '.', LPAD(CONVERT(Arbol.OrdenMenu, char(3)), 2,'0'));
        DROP TEMPORARY TABLE aux;
		SET pNivel = pNivel + 1;
    END LOOP armar_arbol;
    SELECT	IdModeloReporte, IdModeloReportePadre, Reporte, NombreMenu, Ayuda, EsHoja, Nivel, Ordenar FROM Arbol ORDER BY Ordenar;
    
    DROP TEMPORARY TABLE IF EXISTS Arbol, aux;
    
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;