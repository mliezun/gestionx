DROP TRIGGER IF EXISTS `ExistenciasConsolidadas_AFTER_INSERT`;
DELIMITER $$
CREATE DEFINER = CURRENT_USER TRIGGER `ExistenciasConsolidadas_AFTER_INSERT` AFTER INSERT ON `ExistenciasConsolidadas` FOR EACH ROW
BEGIN
    INSERT INTO aud_ExistenciasConsolidadas VALUES(0, NOW(), SUBSTRING_INDEX(USER(),'@',1), SUBSTRING_INDEX(USER(),'@',-1), NULL,
    SUBSTRING_INDEX(USER(),'@',-1), NULL, 'I', NEW.IdArticulo, NEW.IdPuntoVenta, NEW.IdCanal, NEW.Cantidad);
END$$
DELIMITER ;
