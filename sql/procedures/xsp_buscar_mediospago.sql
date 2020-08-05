DROP PROCEDURE IF EXISTS `xsp_buscar_mediospago`;
DELIMITER $$
CREATE PROCEDURE `xsp_buscar_mediospago`(pTipo char(1))
BEGIN
	/*
    Permite listar los medios de pago activos para un tipo de entidad pagable determinada.
    */
    CASE pTipo 
        WHEN 'P' THEN
            SELECT		mp.*
            FROM		MediosPago mp
            WHERE		mp.Estado = 'A'
                        AND mp.IdMedioPago NOT IN (
                            -- Mercaderia
                            2,
                            -- Descuento
                            8
                        )
            ORDER BY    mp.MedioPago;
        WHEN 'C' THEN
            SELECT		mp.*
            FROM		MediosPago mp
            WHERE		mp.Estado = 'A'
                        AND mp.IdMedioPago NOT IN (
                            -- Mercaderia
                            2,
                            -- Descuento
                            8,
                            -- Nota de Credito
                            9,
                            -- Nota de Debito
                            10
                        )
            ORDER BY    mp.MedioPago;
        WHEN 'V' THEN
            SELECT		mp.*
            FROM		MediosPago mp
            WHERE		mp.Estado = 'A'
                        AND mp.IdMedioPago NOT IN (
                            -- Nota de Credito
                            9,
                            -- Nota de Debito
                            10
                        )
            ORDER BY    mp.MedioPago;
        ELSE
            SELECT		mp.*
            FROM		MediosPago mp
            WHERE		mp.Estado = 'A'
            ORDER BY    mp.MedioPago;
    END CASE;
END$$

DELIMITER ;