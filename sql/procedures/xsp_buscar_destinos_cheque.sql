DROP PROCEDURE IF EXISTS `xsp_buscar_destinos_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_destinos_cheque`(pIdEmpresa int, pCadena varchar(30), pEstado char(1))
BEGIN
	/*
    * Permite buscar los destinos de cheque dada una cadena de búsqueda, y el estado.
    * Para listar todos, cadena vacía.
    */
    SELECT		dc.*
    FROM		DestinosCheque dc
    WHERE		dc.IdEmpresa = pIdEmpresa
                AND (dc.Destino LIKE CONCAT('%', pCadena, '%'))
                AND (dc.Estado = pEstado OR pEstado = 'T');
END$$

DELIMITER ;