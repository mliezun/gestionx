DROP PROCEDURE IF EXISTS `xsp_dame_suscripcion_por_datos`;

DELIMITER $$
CREATE PROCEDURE `xsp_dame_suscripcion_por_datos`(pDatos json)
BEGIN
    /*
    Permite instanciar una suscripción desde la base de datos a partir de los datos json.
    */
    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
    IF pDatos->>'$.Proveedor' = 'Paypal' THEN
        SELECT  *
        FROM    Suscripciones
        WHERE   Datos->>'$.Proveedor' = 'Paypal' AND Datos->>'$.Mensaje.id' = pDatos->>'$.Mensaje.id';
    END IF;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END $$

DELIMITER ;