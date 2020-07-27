DROP PROCEDURE IF EXISTS `xsp_dame_suscripciones_usuario`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_suscripciones_usuario`(pIdusuario bigint)
BEGIN
    /*
    Permite obtener todas las suscripciones del usuario indicado.
    */
    SELECT * FROM Suscripciones WHERE IdUsuario = pIdusuario;
END $$

DELIMITER ;