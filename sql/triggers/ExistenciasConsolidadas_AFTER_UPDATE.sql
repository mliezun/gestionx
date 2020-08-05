DROP TRIGGER IF EXISTS `ExistenciasConsolidadas_AFTER_UPDATE`;
DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER `ExistenciasConsolidadas_AFTER_UPDATE` AFTER UPDATE ON `ExistenciasConsolidadas` FOR EACH ROW
BEGIN
	INSERT INTO aud_ExistenciasConsolidadas VALUES(0, NOW(), SUBSTRING_INDEX(USER(),'@',1), SUBSTRING_INDEX(USER(),'@',-1), NULL,
    SUBSTRING_INDEX(USER(),'@',-1), NULL, 'A', OLD.IdArticulo, OLD.IdPuntoVenta, OLD.IdCanal, OLD.Cantidad);
    INSERT INTO aud_ExistenciasConsolidadas VALUES(0, NOW(), SUBSTRING_INDEX(USER(),'@',1), SUBSTRING_INDEX(USER(),'@',-1), NULL,
    SUBSTRING_INDEX(USER(),'@',-1), NULL, 'D', NEW.IdArticulo, NEW.IdPuntoVenta, NEW.IdCanal, NEW.Cantidad);
END$$
DELIMITER ;
