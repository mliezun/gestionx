DROP PROCEDURE IF EXISTS `xsp_buscar_bancos`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_bancos`(pIdEmpresa int, pCadena varchar(30), pEstado char(1))
BEGIN
	/*
    * Permite buscar los bancos dada una cadena de búsqueda, el tipo de banco (T para listar todas) y el estado.
    * Para listar todos, cadena vacía.
    */
    SELECT		b.*
    FROM		Bancos b
    WHERE		b.IdEmpresa = pIdEmpresa
                AND (b.Banco LIKE CONCAT('%', pCadena, '%'))
                AND (b.Estado = pEstado OR pEstado = 'T');
END$$

DELIMITER ;