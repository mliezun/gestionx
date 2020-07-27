DROP PROCEDURE IF EXISTS `xsp_buscar_clientes`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_clientes`(pIdEmpresa int, pCadena varchar(30), pTipo char(1), pEstado char(1))
BEGIN
	/*
    * Permite buscar los clientes dada una cadena de búsqueda, el tipo de cliente (T para listar todas) y el estado.
    * Para listar todos, cadena vacía.
    */
    SELECT		c.*, lp.Lista, tda.TipoDocAfip
    FROM		Clientes c
    INNER JOIN  ListasPrecio lp USING(IdListaPrecio)
    INNER JOIN  TiposDocAfip tda USING(IdTipoDocAfip)
    WHERE		c.IdEmpresa = pIdEmpresa
                AND (c.Tipo = pTipo OR pTipo = 'T')
                AND (c.Estado = pEstado OR pEstado = 'T')
                AND (
                    c.Nombres LIKE CONCAT('%', pCadena, '%') OR
                    c.Apellidos LIKE CONCAT('%', pCadena, '%') OR
                    c.RazonSocial LIKE CONCAT('%', pCadena, '%')
                );
END$$

DELIMITER ;