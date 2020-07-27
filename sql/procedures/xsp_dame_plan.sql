DROP PROCEDURE IF EXISTS `xsp_dame_plan`;
DELIMITER $$
CREATE PROCEDURE `xsp_dame_plan`(pIdPlan SMALLINT, pCodigoDesc CHAR(7))
PROC: BEGIN
	/*
	Busca un plan y devuelve los datos del plan. Si se indica un codigo de descuento,
	devuelve el precio final de utilizar ese codigo de descuento.
	La columna Descuento indica el valor total del descuento calculado.
	*/
	DECLARE pDescuentoPorcent TINYINT;

	IF pDescuentoPorcent IS NULL THEN
		SET pDescuentoPorcent = 0;
	END IF;

	SELECT IdPlan, Plan, CantDias, (Precio - (Precio * pDescuentoPorcent / 100)) Precio, (Precio * pDescuentoPorcent / 100) Descuento, Moneda, Descripcion
	FROM Planes
	WHERE IdPlan = pIdPlan
	AND Estado = 'A';

END $$

DELIMITER ;