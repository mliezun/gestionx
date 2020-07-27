DROP PROCEDURE IF EXISTS `xsp_alta_empresa`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_empresa`(pToken varchar(500), pEmpresa varchar(100), pURL varchar(255), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
PROC: BEGIN
	/*
	Permite dar de alta una nueva empresa, junto con todos los parámetros de empresa por defecto.
    Verifica que el nombre de la empresa no exista ya.
    Devuelve OK + Id o el mensaje de error en Mensaje.
    */
    DECLARE pIdEmpresa, pIdRol int;
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        -- show errors;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
    END;
    
    call xsp_puede_ejecutar(pToken, 'xsp_alta_empresa', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN
		SELECT pMensaje Mensaje;
        LEAVE PROC;
    END IF;
    
    IF EXISTS (SELECT IdEmpresa FROM Empresas WHERE Empresa = pEmpresa) THEN
		SELECT 'No se puede dar de alta la empresa. Ya existe una empresa con el mismo nombre.' Mensaje;
        LEAVE PROC;
    END IF;
    
    IF EXISTS (SELECT IdEmpresa FROM Empresas WHERE URL = pURL) THEN
		SELECT 'No se puede dar de alta la empresa. Ya existe una empresa con la misma URL.' Mensaje;
        LEAVE PROC;
    END IF;
    
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        
		INSERT INTO Empresas SELECT 0, pEmpresa, pURL, 'A';

        SET pIdEmpresa = LAST_INSERT_ID();

        INSERT INTO ModulosEmpresas VALUES (pIdEmpresa, 1), (pIdEmpresa, 2);

        INSERT INTO aud_Empresas
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I', Empresas.*
        FROM Empresas WHERE IdEmpresa = pIdEmpresa;
        
        call xsp_generar_datos_empresa(pIdEmpresa, pMensaje);
        IF pMensaje != 'OK' THEN
            SELECT pMensaje Mensaje;
            ROLLBACK;
            LEAVE PROC;
        END IF;
        
        SELECT CONCAT('OK', pIdEmpresa) Mensaje;
    COMMIT;
END$$

DELIMITER ;