DROP PROCEDURE IF EXISTS `xsp_buscar_cheques`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_cheques`(pIdEmpresa int, pCadena varchar(30), pFechaInicio date, pFechaFin date, pEstado char(1), pTipo char(1), pIdCliente bigint)
BEGIN
	/*
    * Permite buscar los cheques dada una cadena de búsqueda, el tipo de cheque (T: para listar todas, C: clientes, P: propios), el estado
    * y una fecha de inicio y fin.
    * Para listar todos, cadena vacía.
    */
    DECLARE pFechaAux date;
    SET pFechaInicio = COALESCE(pFechaInicio, '1900-01-01');
    SET pFechaFin = COALESCE(pFechaFin, '9999-12-31');
    IF pFechaFin < pFechaInicio THEN
        SET pFechaAux = pFechaFin;
        SET pFechaFin = pFechaInicio;
        SET pFechaInicio = pFechaAux;
    END IF;
    SELECT		c.*, b.Banco, dc.Destino,
                IF(cl.IdCliente IS NOT NULL,
                    IF(cl.RazonSocial IS NULL OR cl.RazonSocial = '', CONCAT(cl.Apellidos, ', ', cl.Nombres), cl.RazonSocial),
                    'Cheque propio') Descripcion
    FROM		Cheques c
    INNER JOIN  Bancos b USING(IdBanco)
    LEFT JOIN   Clientes cl USING(IdCliente)
    LEFT JOIN   DestinosCheque dc USING(IdDestinoCheque)
    WHERE		b.IdEmpresa = pIdEmpresa AND IF(pIdCliente IS NOT NULL, c.IdCliente=pIdCliente, 1)
                AND (c.FechaVencimiento BETWEEN pFechaInicio AND pFechaFin)
                AND (
                    b.Banco LIKE CONCAT('%', pCadena, '%') OR
                    CONCAT(c.NroCheque, '') LIKE CONCAT('%', pCadena, '%')
                )
                AND (c.Estado = pEstado OR pEstado = 'T')
                AND (cl.IdCliente IS NULL 
                    OR cl.RazonSocial LIKE CONCAT('%', pCadena, '%')
                    OR cl.Apellidos LIKE CONCAT('%', pCadena, '%')
                    OR cl.Nombres LIKE CONCAT('%', pCadena, '%')
                )
                AND (dc.IdDestinoCheque IS NULL 
                    OR dc.Destino LIKE CONCAT('%', pCadena, '%')
                )
                AND IF(pTipo = 'P', IdCliente IS NULL, 1)
                AND IF(pTipo = 'C', IdCliente IS NOT NULL, 1)
    ORDER BY    c.FechaAlta desc, c.FechaVencimiento ASC;
END$$

DELIMITER ;