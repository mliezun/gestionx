DROP PROCEDURE IF EXISTS `xsp_dame_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_destino_cheque`(pIdDestinoCheque smallint)
BEGIN
	/*
    * Procedimiento que sirve para instanciar un destino de cheque desde la base de datos.
    */
	SELECT	*
    FROM	DestinosCheque
    WHERE	IdDestinoCheque = pIdDestinoCheque;
END$$

DELIMITER ;