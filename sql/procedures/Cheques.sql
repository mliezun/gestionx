DROP PROCEDURE IF EXISTS `xsp_alta_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_cheque`(pToken varchar(500), pIdCliente bigint, pIdBanco smallint, pIdDestinoCheque smallint,
pNroCheque bigint, pImporte decimal(12,2), pFechaVencimiento date, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un Cheque.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdCheque bigint;
    DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdBanco FROM Bancos WHERE IdBanco = pIdBanco AND Estado = 'A') THEN
		SELECT 'No existe el banco indicado.' Mensaje;
		LEAVE SALIR;
	END IF;

    IF (pIdDestinoCheque IS NOT NULL) THEN
        IF NOT EXISTS(SELECT IdDestinoCheque FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque AND Estado = 'A') THEN
            SELECT 'No existe el destino indicado.' Mensaje;
            LEAVE SALIR;
        END IF;
    END IF;

    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Inserta
        INSERT INTO Cheques SELECT 0, pIdCliente, pIdBanco, pIdDestinoCheque, pNroCheque, pImporte, NOW(), pFechaVencimiento, 'D', pObservaciones;
        SET pIdCheque = LAST_INSERT_ID();
		-- Audita
		INSERT INTO aud_Cheques
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        Cheques.* FROM Cheques WHERE IdCheque = pIdCheque;
        
        SELECT CONCAT('OK', pIdCheque) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_cheque`(pToken varchar(500), pIdCheque bigint,
pIdCliente bigint, pIdBanco smallint, pIdDestinoCheque smallint, pNroCheque bigint, pImporte decimal(12,2),
pFechaVencimiento date, pObservaciones text,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un Cheque.
	* Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		 SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdCheque IS NULL OR pIdCheque = 0) THEN
        SELECT 'Debe indicar el cheque.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT IdCheque FROM Cheques WHERE IdCheque = pIdCheque AND Estado = 'D') THEN
		SELECT 'El cheque indicado no existe.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_Cheques
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'A', Cheques.*
        FROM Cheques WHERE IdCheque = pIdCheque;
        -- Modifica
        UPDATE  Cheques 
		SET	    IdCliente=pIdCliente,
                IdBanco=pIdBanco,
                IdDestinoCheque=pIdDestinoCheque,
                NroCheque=pNroCheque,
                Importe=pImporte,
                FechaVencimiento=pFechaVencimiento,
                Obversaciones=pObservaciones
		WHERE   IdCheque=pIdCheque;
		-- Despues
        INSERT INTO aud_Cheques
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D', Cheques.*
        FROM Cheques WHERE IdCheque = pIdCheque;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_borra_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_cheque`(pToken varchar(500), pIdCheque bigint, pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un cheque controlando que no tenga ingresos o ventas asosiadas.
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_cheque', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdCheque FROM Cheques WHERE IdCheque = pIdCheque) THEN
        SELECT 'El cheque indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdCheque FROM Pagos WHERE IdCheque = pIdCheque) THEN
        SELECT 'El cheque indicado no se puede borrar, tiene pagos asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS (SELECT IdCheque FROM PagosProveedor WHERE IdCheque = pIdCheque) THEN
        SELECT 'El cheque indicado no se puede borrar, tiene pagos de proveedores asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_Cheques
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A', Cheques.*
        FROM Cheques WHERE IdCheque = pIdCheque;
        -- Borro
        DELETE FROM Cheques WHERE IdCheque = pIdCheque;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

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
    ORDER BY    c.FechaVencimiento ASC;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_alta_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_alta_destino_cheque`(pToken varchar(500), pIdEmpresa int,
pDestino varchar(100), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/**
    * Permite dar de alta un destino de cheque controlando que el nombre del destino no exista ya.
	* Devuelve OK + Id o el mensaje de error en Mensaje.
    */
	DECLARE pIdDestinoCheque smallint;
    DECLARE pIdUsuario bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_alta_destino_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdEmpresa IS NULL OR pIdEmpresa = 0) THEN
        SELECT 'Debe ingresar la empresa.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDestino IS NULL OR pDestino = '') THEN
        SELECT 'Debe ingresar el destino.' Mensaje;
        LEAVE SALIR;
	END IF;

	-- Control de Parametros incorrectos
    IF NOT EXISTS(SELECT Empresa FROM Empresas E WHERE E.IdEmpresa = pIdEmpresa) THEN
		SELECT 'Debe existir la empresa dada.' Mensaje;
		LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT IdDestinoCheque FROM DestinosCheque WHERE Destino = pDestino AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe un destino con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;

    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        INSERT INTO DestinosCheque SELECT 0, pIdEmpresa, pDestino, 'A';
        SET pIdDestinoCheque = LAST_INSERT_ID();
        -- Audita
		INSERT INTO aud_DestinosCheque
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ALTA', 'I',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
        
        SELECT CONCAT('OK', pIdDestinoCheque) Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_modifica_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_modifica_destino_cheque`(pToken varchar(500), pIdDestinoCheque smallint,
pDestino varchar(100), pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite modificar un DestinoCheque.
	* Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuario, pIdEmpresa bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_modifica_destino_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF (pIdDestinoCheque IS NULL OR pIdDestinoCheque = 0) THEN
        SELECT 'Debe indicar el destino.' Mensaje;
        LEAVE SALIR;
	END IF;
	IF (pDestino IS NULL OR TRIM(pDestino) = '') THEN
        SELECT 'Debe indicar el nombre del destino.' Mensaje;
        LEAVE SALIR;
	END IF;
    SET pIdEmpresa = (SELECT IdEmpresa FROM Usuarios WHERE IdUsuario = pIdUsuario);
	-- Control de Parametros incorrectos
    IF EXISTS(SELECT IdDestinoCheque FROM DestinosCheque WHERE Destino = pDestino AND IdDestinoCheque != pIdDestinoCheque AND IdEmpresa = pIdEmpresa) THEN
		SELECT 'Ya existe otro destino con el nombre indicado.' Mensaje;
		LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
        -- Antes
        INSERT INTO aud_DestinosCheque
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
        -- Modifica
        UPDATE DestinosCheque 
		SET	   Destino = pDestino
		WHERE  IdDestinoCheque=pIdDestinoCheque;
		-- Despues
        INSERT INTO aud_DestinosCheque
        SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'MODIFICA', 'D',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;

        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS `xsp_borra_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_borra_destino_cheque`(pToken varchar(500), pIdDestinoCheque smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR: BEGIN
	/*
	* Permite borrar un destino controlando que no tenga cheques asosiados.
    * Devuelve OK o el mensaje de error en Mensaje.
	*/
	DECLARE pIdUsuarioGestion bigint;
    DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
	-- Manejo de error en la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		-- SHOW ERRORS;
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros Vacios
    CALL xsp_puede_ejecutar(pToken, 'xsp_borra_destino_cheque', pMensaje, pIdUsuarioGestion);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF NOT EXISTS (SELECT IdDestinoCheque FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque) THEN
        SELECT 'El destino indicado no existe.' Mensaje;
        LEAVE SALIR;
	END IF;
	-- Control de Parámetros incorrectos
    IF EXISTS (SELECT IdCheque FROM Cheques WHERE IdDestinoCheque = pIdDestinoCheque) THEN
        SELECT 'El destino indicado no se puede borrar, tiene cheques asociados.' Mensaje;
        LEAVE SALIR;
	END IF;
    START TRANSACTION;
        SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuarioGestion);
        -- Audito
        INSERT INTO aud_DestinosCheque
        SELECT 0, NOW(), CONCAT(pIdUsuarioGestion,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'BORRA', 'A',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;

        -- Borro
        DELETE FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

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

DROP PROCEDURE IF EXISTS `xsp_activar_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_activar_destino_cheque`(pToken varchar(500), pIdDestinoCheque smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite cambiar el estado del Destino de cheque a Activo siempre y cuando no esté activo ya.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_activar_destino_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque AND Estado = 'A') THEN
		SELECT 'El Destino ya está activado.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_DestinosCheque
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'A',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
		-- Activa Destino
		UPDATE DestinosCheque SET Estado = 'A' WHERE IdDestinoCheque = pIdDestinoCheque;
		-- Después
		INSERT INTO aud_DestinosCheque
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'ACTIVAR', 'D',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `xsp_darbaja_destino_cheque`;
DELIMITER $$
CREATE PROCEDURE `xsp_darbaja_destino_cheque`(pToken varchar(500), pIdDestinoCheque smallint,
pIP varchar(40), pUserAgent varchar(255), pAplicacion varchar(50))
SALIR:BEGIN
	/*
    * Permite dar de baja a un Destino de cheque siempre y cuando no esté dado de baja ya.
    * Devuelve OK o el mensaje de error en Mensaje.
    */
	DECLARE pIdUsuario bigint;
	DECLARE pUsuario varchar(30);
    DECLARE pMensaje varchar(100);
    -- Manejo de error en la transacción    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SELECT 'Error en la transacción. Contáctese con el administrador.' Mensaje;
        ROLLBACK;
	END;
    -- Controla Parámetros
    CALL xsp_puede_ejecutar(pToken, 'xsp_darbaja_destino_cheque', pMensaje, pIdUsuario);
    IF pMensaje != 'OK' THEN 
		SELECT pMensaje Mensaje;
        LEAVE SALIR;
	END IF;
    IF EXISTS(SELECT Estado FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque AND Estado = 'B') THEN
		SELECT 'El Destino ya está dado de baja.' Mensaje;
        LEAVE SALIR;
	END IF;
    
    START TRANSACTION;
		SET pUsuario = (SELECT Usuario FROM Usuarios WHERE IdUsuario = pIdUsuario);
		-- Antes
		INSERT INTO aud_DestinosCheque
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'A',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
		
        -- Da de Baja Destino
		UPDATE DestinosCheque SET Estado = 'B' WHERE IdDestinoCheque = pIdDestinoCheque;

		-- Después
		INSERT INTO aud_DestinosCheque
		SELECT 0, NOW(), CONCAT(pIdUsuario,'@',pUsuario), pIP, pUserAgent, pAplicacion, 'DARBAJA', 'D',
        DestinosCheque.* FROM DestinosCheque WHERE IdDestinoCheque = pIdDestinoCheque;
		
        SELECT 'OK' Mensaje;
	COMMIT;
END$$
DELIMITER ;

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
