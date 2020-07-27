DROP function IF EXISTS `f_aud_motivo`;
DELIMITER $$
CREATE FUNCTION `f_aud_motivo`(pMotivo varchar(100), pAutoriza varchar(100)) RETURNS varchar(100) CHARSET latin1
    DETERMINISTIC
BEGIN
-- Permite auditar el motivo
RETURN concat(pMotivo, '#', pAutoriza);
END$$

DELIMITER ;