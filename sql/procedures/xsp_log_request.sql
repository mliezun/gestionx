DROP PROCEDURE IF EXISTS `xsp_log_request`;
DELIMITER $$
CREATE PROCEDURE `xsp_log_request`(pEndpoint varchar(100), pDatos json)
BEGIN
	/*
    Permite loguear un pedido de cotización a la API forex. Si el resultado es OK, entonces actualiza la cotización de la moneda.
    */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'TRXERR' Mensaje;
        ROLLBACK;
	END;

	START TRANSACTION;
		INSERT INTO LogRequests
        SELECT      NOW(6), pEndpoint, pDatos;
    COMMIT;
    
    SELECT 'OK' Mensaje;
END $$

DELIMITER ;