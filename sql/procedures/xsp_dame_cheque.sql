DROP PROCEDURE IF EXISTS `xsp_dame_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_cheque`(pIdCheque bigint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar un cheque desde la base de datos.
    */
	SELECT	c.*, b.Banco, dc.Destino,
                IF(cl.IdCliente IS NOT NULL,
                    IF(cl.RazonSocial IS NULL, CONCAT(cl.Apellidos, ', ', cl.Nombres), cl.RazonSocial),
                    'Cheque propio') Descripcion
    FROM	Cheques c
    INNER JOIN  Bancos b USING(IdBanco)
    LEFT JOIN   Clientes cl USING(IdCliente)
    LEFT JOIN   DestinosCheque dc USING(IdDestinoCheque)
    WHERE	IdCheque = pIdCheque;
END$$

DELIMITER ;