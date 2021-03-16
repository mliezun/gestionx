DROP PROCEDURE IF EXISTS `xsp_reporte_mercaderia`;
DELIMITER $$
CREATE PROCEDURE `xsp_reporte_mercaderia`(
    pIdEmpresa int,
    pFechaInicio date,
    pFechaFin date,
    pIdProveedor bigint
)
BEGIN
    DECLARE pTotal, pCantidad DECIMAL(14,2);
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_mercaderia;
    CREATE TEMPORARY TABLE tmp_inf_mercaderia
        SELECT      i.IdIngreso, i.FechaAlta 'Fecha',
                    COALESCE(li.Cantidad, 0) `Cantidad`,
                    a.Articulo `Artículo`,
                    COALESCE(li.Precio, 0) `Precio`,
                    COALESCE(li.Cantidad * li.Precio, 0) `$ Monto`
        FROM        Ingresos i
        INNER JOIN  Remitos r USING(IdRemito)
        INNER JOIN  LineasIngreso li ON i.IdIngreso = li.IdIngreso
        INNER JOIN  Articulos a USING(IdArticulo)
        INNER JOIN  Proveedores pr ON r.IdProveedor = pr.IdProveedor
        WHERE       i.IdEmpresa = pIdEmpresa AND i.Estado IN ("A", "I") AND
                    r.IdProveedor = pIdProveedor AND
                    (i.FechaAlta BETWEEN pFechaInicio AND CONCAT(pFechaFin, ' 23:59:59')) 
        ORDER BY    i.IdIngreso DESC;


    SELECT  SUM(`$ Monto`), SUM(`Cantidad`)
    INTO    pTotal, pCantidad
    FROM    tmp_inf_mercaderia;

    SELECT      CONCAT(pFechaFin, ' 23:59:59') Fecha, pCantidad `Cantidad`, 'Acumulado' `Artículo`, pTotal `$ Monto`
    UNION ALL
    SELECT      `Fecha`, `Cantidad`, `Artículo`, `$ Monto`
    FROM        tmp_inf_mercaderia
    ORDER BY    Fecha DESC;


    DROP TEMPORARY TABLE IF EXISTS tmp_inf_mercaderia;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;