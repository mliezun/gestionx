DROP PROCEDURE IF EXISTS `xsp_reporte_compras`;
DELIMITER $$
CREATE PROCEDURE `xsp_reporte_compras`(
    pIdEmpresa int,
    pFechaInicio date,
    pFechaFin date,
    pIdProveedor bigint
)
BEGIN
    DECLARE pTotal, pRemito, pFactura DECIMAL(14,2);
    SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DROP TEMPORARY TABLE IF EXISTS tmp_inf_proveedores;
    CREATE TEMPORARY TABLE tmp_inf_proveedores
        SELECT      i.IdIngreso, i.FechaAlta 'Fecha',
                    IF(r.NroFactura IS NULL OR r.NroFactura = 0 , CONCAT('Remito #', COALESCE(r.NroRemito, 0)), CONCAT('Factura #', r.NroFactura)) 'Descripción',
                    COALESCE(SUM(li.Cantidad * li.Precio), 0) '$ Monto',
                    COALESCE(IF(r.NroFactura IS NULL OR r.NroFactura = 0 , SUM(li.Cantidad * li.Precio), 0), 0) '$ Remito',
                    COALESCE(IF(r.NroFactura IS NULL OR r.NroFactura = 0 , 0, SUM(li.Cantidad * li.Precio)), 0) '$ Factura',
                    CONCAT(u.Nombres, ' ', u.Apellidos) Vendedor
        FROM        Ingresos i
        INNER JOIN  Remitos r USING(IdRemito)
        INNER JOIN  LineasIngreso li ON i.IdIngreso = li.IdIngreso
        INNER JOIN  Proveedores pr USING(IdProveedor)
        INNER JOIN  Usuarios u ON i.IdUsuario = u.IdUsuario
        WHERE       i.IdEmpresa = pIdEmpresa AND i.Estado IN ("A", "I") AND
                    r.IdProveedor = pIdProveedor AND
                    (i.FechaAlta BETWEEN pFechaInicio AND CONCAT(pFechaFin, ' 23:59:59')) 
        GROUP BY    i.IdIngreso
        ORDER BY    i.IdIngreso DESC;


    SELECT  SUM(`$ Monto`), SUM(`$ Remito`), SUM(`$ Factura`)
    INTO    pTotal, pRemito, pFactura
    FROM    tmp_inf_proveedores;

    SELECT      CONCAT(pFechaFin, ' 23:59:59') Fecha, 'Estado' `Descripción`, pTotal `$ Monto`,
                pRemito `$ Remito`, pFactura `$ Factura`
    UNION ALL
    SELECT      `Fecha`, `Descripción`, `$ Monto`,
                `$ Remito`, `$ Factura`
    FROM        tmp_inf_proveedores
    ORDER BY    Fecha DESC;


    DROP TEMPORARY TABLE IF EXISTS tmp_inf_proveedores;
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END$$

DELIMITER ;