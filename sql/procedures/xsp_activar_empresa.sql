DROP PROCEDURE IF EXISTS `xsp_activar_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_empresa`(pToken varchar(500), pIdEmpresa int, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
	/*
	Permite activar una empresa, controlando que exista y se encuentre dada de baja.
    Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
    END;
    
    call xsp_puede_ejecutar(pToken, 'xsp_activar_empresa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN
		SELECT pMensaje Mensaje;
        LEAVE PROC;
    END IF;
    
    IF EXISTS (SELECT IdEmpresa FROM Empresas WHERE IdEmpresa = pIdEmpresa AND Estado = 'A') THEN
		SELECT 'La empresa ya se encuentra activa.' Mensaje;
        LEAVE PROC;
    END IF;
    
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);

        INSERT INTO aud_Empresas
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A', Empresas.*
        FROM Empresas WHERE IdEmpresa = pIdEmpresa;
        
		UPDATE Empresas SET Estado = 'A' WHERE IdEmpresa = pIdEmpresa;

        INSERT INTO aud_Empresas
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D', Empresas.*
        FROM Empresas WHERE IdEmpresa = pIdEmpresa;
        
        SELECT 'OK' Mensaje;
    COMMIT;
END$$

DELIMITER ;