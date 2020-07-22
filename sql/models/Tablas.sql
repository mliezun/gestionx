--
-- ER/Studio 8.0 SQL Code Generation
-- Company :      *
-- Project :      Modelos.DM1
-- Author :       GestionX
--
-- Date Created : Lunes, Noviembre 18, 2019 17:49:37
-- Target DBMS : MySQL 5.x
--

-- 
-- TABLE: Articulos 
--

CREATE TABLE Articulos(
    IdArticulo     BIGINT            NOT NULL,
    IdProveedor    BIGINT            NOT NULL,
    IdEmpresa      INT               NOT NULL,
    IdTipoIVA      TINYINT           NOT NULL,
    Articulo       VARCHAR(255)      NOT NULL,
    Codigo         VARCHAR(255)      NOT NULL,
    Descripcion    TEXT,
    PrecioCosto    DECIMAL(12, 2)    NOT NULL,
    FechaAlta      DATETIME          NOT NULL,
    Estado         CHAR(1)           NOT NULL,
    PRIMARY KEY (IdArticulo)
)ENGINE=INNODB
;



-- 
-- TABLE: Bancos 
--

CREATE TABLE Bancos(
    IdBanco      SMALLINT        NOT NULL,
    IdEmpresa    INT             NOT NULL,
    Banco        VARCHAR(100)    NOT NULL,
    Estado       CHAR(1)         NOT NULL,
    PRIMARY KEY (IdBanco)
)
;



-- 
-- TABLE: Canales 
--

CREATE TABLE Canales(
    IdCanal          BIGINT         NOT NULL,
    IdEmpresa        INT            NOT NULL,
    Canal            VARCHAR(50)    NOT NULL,
    Estado           CHAR(1)        NOT NULL,
    Observaciones    TEXT           NULL,
    PRIMARY KEY (IdCanal)
)
;



-- 
-- TABLE: Cheques 
--

CREATE TABLE Cheques(
    IdCheque            BIGINT            NOT NULL,
    IdCliente           BIGINT,
    IdBanco             SMALLINT          NOT NULL,
    IdDestinoCheque     SMALLINT          NOT NULL,
    NroCheque           BIGINT            NOT NULL,
    Importe             DECIMAL(10, 2)    NOT NULL,
    FechaAlta           DATETIME          NOT NULL,
    FechaVencimiento    DATE              NOT NULL,
    Estado              CHAR(1)           NOT NULL,
    Obversaciones       TEXT,
    PRIMARY KEY (IdCheque)
)
;



-- 
-- TABLE: Clientes 
--

CREATE TABLE Clientes(
    IdCliente        BIGINT          NOT NULL,
    IdEmpresa        INT             NOT NULL,
    IdListaPrecio    BIGINT          NOT NULL,
    IdTipoDocAfip    TINYINT         NOT NULL,
    Nombres          VARCHAR(255),
    Apellidos        VARCHAR(255),
    RazonSocial      VARCHAR(255),
    Documento        CHAR(10)        NOT NULL,
    Datos            TEXT            NOT NULL,
    FechaAlta        DATETIME        NOT NULL,
    Tipo             CHAR(1)         NOT NULL,
    Estado           CHAR(1)         NOT NULL,
    Observaciones    TEXT,
    PRIMARY KEY (IdCliente)
)ENGINE=INNODB
;



-- 
-- TABLE: Comprobantes 
--

CREATE TABLE Comprobantes(
    IdPago               BIGINT      NOT NULL,
    IdTipoComprobante    SMALLINT    NOT NULL,
    RutaArchivo          TEXT,
    FechaGenerado        DATETIME,
    PRIMARY KEY (IdPago)
)ENGINE=INNODB
;


-- 
-- TABLE: ComprobantesVentas
--

CREATE TABLE `ComprobantesVentas` (
  `IdComprobanteAfip` bigint(20) NOT NULL AUTO_INCREMENT,
  `IdVenta` bigint(20) NOT NULL,
  `IdTipoComprobanteAfip` smallint(6) DEFAULT NULL,
  `NroComprobante` int(11) DEFAULT NULL,
  `FechaGenerado` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`IdComprobanteAfip`),
  UNIQUE KEY `UI_IdVentaIdTipoComprobanteAfip` (`IdVenta`,`IdTipoComprobanteAfip`)
) ENGINE=InnoDB;


-- 
-- TABLE: DestinoCheque 
--

CREATE TABLE DestinoCheque(
    IdDestinoCheque    SMALLINT       NOT NULL,
    IdEmpresa          INT            NOT NULL,
    Destino            VARCHAR(10),
    Estado             CHAR(10),
    PRIMARY KEY (IdDestinoCheque)
)
;



-- 
-- TABLE: Empresas 
--

CREATE TABLE Empresas(
    IdEmpresa    INT             NOT NULL,
    Empresa      VARCHAR(100)    NOT NULL,
    URL          VARCHAR(255)    NOT NULL,
    Estado       CHAR(1)         NOT NULL,
    PRIMARY KEY (IdEmpresa)
)ENGINE=INNODB
;



-- 
-- TABLE: ExistenciasConsolidadas 
--

CREATE TABLE ExistenciasConsolidadas(
    IdArticulo      BIGINT            NOT NULL,
    IdPuntoVenta    BIGINT            NOT NULL,
    IdCanal         BIGINT            NOT NULL,
    Cantidad        DECIMAL(12, 2)    NOT NULL,
    PRIMARY KEY (IdArticulo, IdPuntoVenta)
)ENGINE=INNODB
;



-- 
-- TABLE: HistorialDescuentos 
--

CREATE TABLE HistorialDescuentos(
    IdHistorial    BIGINT            AUTO_INCREMENT,
    IdProveedor    BIGINT            NOT NULL,
    Descuento      DECIMAL(10, 4)    NOT NULL,
    FechaAlta      DATETIME          NOT NULL,
    FechaFin       DATETIME,
    PRIMARY KEY (IdHistorial)
)
;



-- 
-- TABLE: HistorialPorcentajes 
--

CREATE TABLE HistorialPorcentajes(
    IdHistorial      BIGINT            AUTO_INCREMENT,
    IdListaPrecio    BIGINT            NOT NULL,
    Porcentaje       DECIMAL(10, 0)    NOT NULL,
    FechaAlta        DATETIME          NOT NULL,
    FechaFin         DATETIME,
    PRIMARY KEY (IdHistorial)
)
;



-- 
-- TABLE: HistorialPrecios 
--

CREATE TABLE HistorialPrecios(
    IdHistorial      BIGINT            AUTO_INCREMENT,
    IdArticulo       BIGINT,
    PrecioCosto      DECIMAL(12, 2)    NOT NULL,
    FechaAlta        DATETIME          NOT NULL,
    FechaFin         DATETIME,
    IdListaPrecio    BIGINT,
    PRIMARY KEY (IdHistorial)
)
;



-- 
-- TABLE: Ingresos 
--

CREATE TABLE Ingresos(
    IdIngreso        BIGINT      NOT NULL,
    IdPuntoVenta     BIGINT      NOT NULL,
    IdEmpresa        INT         NOT NULL,
    IdCliente        BIGINT,
    IdRemito         BIGINT,
    IdUsuario        BIGINT      NOT NULL,
    FechaAlta        DATETIME    NOT NULL,
    Estado           CHAR(1)     NOT NULL,
    Observaciones    TEXT,
    PRIMARY KEY (IdIngreso)
)ENGINE=INNODB
;



-- 
-- TABLE: LineasIngreso 
--

CREATE TABLE LineasIngreso(
    IdIngreso     BIGINT            NOT NULL,
    NroLinea      SMALLINT          NOT NULL,
    IdArticulo    BIGINT            NOT NULL,
    Cantidad      DECIMAL(12, 2)    NOT NULL,
    Precio        DECIMAL(12, 2)    NOT NULL,
    PRIMARY KEY (IdIngreso, NroLinea)
)ENGINE=INNODB
;



-- 
-- TABLE: LineasVenta 
--

CREATE TABLE LineasVenta(
    IdVenta       BIGINT            NOT NULL,
    NroLinea      SMALLINT          NOT NULL,
    IdArticulo    BIGINT            NOT NULL,
    Cantidad      DECIMAL(12, 2)    NOT NULL,
    Precio        DECIMAL(12, 2)    NOT NULL,
    Factor        DECIMAL(12, 4)    NOT NULL,
    PRIMARY KEY (IdVenta, NroLinea)
)ENGINE=INNODB
;



-- 
-- TABLE: ListasPrecio 
--

CREATE TABLE ListasPrecio(
    IdListaPrecio    BIGINT            AUTO_INCREMENT,
    IdEmpresa        INT               NOT NULL,
    Lista            VARCHAR(50)       NOT NULL,
    Porcentaje       DECIMAL(10, 4)    NOT NULL,
    Estado           CHAR(1)           NOT NULL,
    Observaciones    TEXT,
    PRIMARY KEY (IdListaPrecio)
)
;



-- 
-- TABLE: MediosPago 
--

CREATE TABLE MediosPago(
    IdMedioPago    SMALLINT        NOT NULL,
    MedioPago      VARCHAR(100)    NOT NULL,
    Estado         CHAR(1)         NOT NULL,
    PRIMARY KEY (IdMedioPago)
)ENGINE=INNODB
;



-- 
-- TABLE: Modulos 
--

CREATE TABLE Modulos(
    IdModulo         TINYINT         NOT NULL,
    Modulo           VARCHAR(100)    NOT NULL,
    Estado           CHAR(1)         NOT NULL,
    Observaciones    TEXT,
    PRIMARY KEY (IdModulo)
)
;



-- 
-- TABLE: ModulosEmpresas 
--

CREATE TABLE ModulosEmpresas(
    IdEmpresa    INT        NOT NULL,
    IdModulo     TINYINT    NOT NULL,
    PRIMARY KEY (IdEmpresa, IdModulo)
)
;



-- 
-- TABLE: Pagos 
--

CREATE TABLE Pagos(
    IdPago            BIGINT            NOT NULL,
    IdVenta           BIGINT            NOT NULL,
    IdMedioPago       SMALLINT          NOT NULL,
    IdUsuario         BIGINT            NOT NULL,
    FechaAlta         DATETIME          NOT NULL,
    FechaDebe         DATETIME          NOT NULL,
    FechaPago         DATETIME          NOT NULL,
    FechaAnula        DATETIME          NOT NULL,
    Monto             DECIMAL(12, 2)    NOT NULL,
    Observaciones     TEXT,
    IdRemito          BIGINT,
    IdCheque          BIGINT,
    NroTarjeta        CHAR(16),
    MesVencimiento    CHAR(2),
    AñoVencimiento    CHAR(2),
    CCV               CHAR(3),
    Datos             JSON,
    PRIMARY KEY (IdPago)
)ENGINE=INNODB
;



-- 
-- TABLE: ParametroEmpresa 
--

CREATE TABLE ParametroEmpresa(
    Parametro    VARCHAR(20)    NOT NULL,
    IdEmpresa    INT            NOT NULL,
    IdModulo     TINYINT        NOT NULL,
    Valor        TEXT           NOT NULL,
    PRIMARY KEY (Parametro, IdEmpresa, IdModulo)
)
;



-- 
-- TABLE: Parametros 
--

CREATE TABLE Parametros(
    Parametro      VARCHAR(20)    NOT NULL,
    IdModulo       TINYINT        NOT NULL,
    Descripcion    TEXT           NOT NULL,
    Rango          VARCHAR(20)    NOT NULL,
    DameValor      TEXT           NOT NULL,
    EsEditable     CHAR(1)        NOT NULL,
    EsInicial      CHAR(1)        NOT NULL,
    PRIMARY KEY (Parametro, IdModulo)
)ENGINE=INNODB
;



-- 
-- TABLE: Permisos 
--

CREATE TABLE Permisos(
    IdPermiso         INT             NOT NULL,
    IdPermisoPadre    INT,
    Permiso           VARCHAR(120)    NOT NULL,
    Descripcion       TEXT            NOT NULL,
    Estado            CHAR(1)         NOT NULL,
    Observaciones     TEXT,
    Orden             TINYINT         NOT NULL,
    Procedimiento     VARCHAR(100),
    IdModulo          TINYINT,
    PRIMARY KEY (IdPermiso)
)ENGINE=INNODB
;



-- 
-- TABLE: PermisosRol 
--

CREATE TABLE PermisosRol(
    IdPermiso    INT    NOT NULL,
    IdRol        INT    NOT NULL,
    PRIMARY KEY (IdPermiso, IdRol)
)ENGINE=INNODB
;



-- 
-- TABLE: PermisosRolGenerico 
--

CREATE TABLE PermisosRolGenerico(
    IdPermiso        INT         NOT NULL,
    IdRolGenerico    SMALLINT    NOT NULL,
    PRIMARY KEY (IdPermiso, IdRolGenerico)
)
;



-- 
-- TABLE: PreciosArticulos 
--

CREATE TABLE PreciosArticulos(
    IdArticulo       BIGINT            NOT NULL,
    IdListaPrecio    BIGINT            NOT NULL,
    PrecioVenta      DECIMAL(12, 2)    NOT NULL,
    PRIMARY KEY (IdArticulo, IdListaPrecio)
)
;



-- 
-- TABLE: Proveedores 
--

CREATE TABLE Proveedores(
    IdProveedor    BIGINT            NOT NULL,
    IdEmpresa      INT               NOT NULL,
    Proveedor      VARCHAR(100)      NOT NULL,
    Descuento      DECIMAL(10, 4)    NOT NULL,
    Estado         CHAR(1)           NOT NULL,
    PRIMARY KEY (IdProveedor, IdEmpresa)
)ENGINE=INNODB
;



-- 
-- TABLE: PuntosVenta 
--

CREATE TABLE PuntosVenta(
    IdPuntoVenta     BIGINT          NOT NULL,
    IdEmpresa        INT             NOT NULL,
    PuntoVenta       VARCHAR(100)    NOT NULL,
    Datos            TEXT            NOT NULL,
    Estado           CHAR(1)         NOT NULL,
    Observaciones    TEXT,
    PRIMARY KEY (IdPuntoVenta, IdEmpresa)
)ENGINE=INNODB
;



-- 
-- TABLE: RectificacionesPV 
--

CREATE TABLE RectificacionesPV(
    IdRectificacionPV      BIGINT            NOT NULL,
    IdArticulo             BIGINT            NOT NULL,
    IdPuntoVentaOrigen     BIGINT            NOT NULL,
    IdPuntoVentaDestino    BIGINT,
    IdEmpresa              INT               NOT NULL,
    IdUsuario              BIGINT            NOT NULL,
    IdCanal                BIGINT            NOT NULL,
    Cantidad               DECIMAL(12, 2)    NOT NULL,
    Estado                 CHAR(1)           NOT NULL,
    FechaAlta              DATETIME          NOT NULL,
    Observaciones          TEXT,
    PRIMARY KEY (IdRectificacionPV)
)ENGINE=INNODB
;



-- 
-- TABLE: Remitos 
--

CREATE TABLE Remitos(
    IdRemito          BIGINT      NOT NULL,
    IdProveedor       BIGINT,
    IdCliente         BIGINT,
    IdEmpresa         INT         NOT NULL,
    IdCanal           BIGINT      NOT NULL,
    NroRemito         CHAR(13)    NOT NULL,
    CAI               BIGINT      NOT NULL,
    NroFactura        BIGINT,
    FechaAlta         DATETIME    NOT NULL,
    FechaFacturado    DATETIME,
    Estado            CHAR(1)     NOT NULL,
    Observaciones     TEXT,
    PRIMARY KEY (IdRemito)
)ENGINE=INNODB
;



-- 
-- TABLE: Roles 
--

CREATE TABLE Roles(
    IdRol            INT            AUTO_INCREMENT,
    Rol              VARCHAR(30)    NOT NULL,
    Estado           CHAR(1)        NOT NULL,
    Observaciones    TEXT,
    IdEmpresa        INT            NOT NULL,
    PRIMARY KEY (IdRol)
)ENGINE=INNODB
;



-- 
-- TABLE: RolesGenericos 
--

CREATE TABLE RolesGenericos(
    IdRolGenerico    SMALLINT       NOT NULL,
    Rol              VARCHAR(30)    NOT NULL,
    Estado           CHAR(1)        NOT NULL,
    Observaciones    TEXT,
    PRIMARY KEY (IdRolGenerico)
)
;



-- 
-- TABLE: SesionesUsuarios 
--

CREATE TABLE SesionesUsuarios(
    IdSesion       BIGINT         AUTO_INCREMENT,
    IdUsuario      BIGINT         NOT NULL,
    FechaInicio    DATETIME       NOT NULL,
    FechaFin       DATETIME,
    IP             VARCHAR(15)    NOT NULL,
    Aplicacion     TEXT           NOT NULL,
    UserAgent      TEXT           NOT NULL,
    PRIMARY KEY (IdSesion)
)ENGINE=INNODB
;



-- 
-- TABLE: TiposComprobante 
--

CREATE TABLE TiposComprobante(
    IdTipoComprobante    SMALLINT        NOT NULL,
    TipoComprobante      VARCHAR(100)    NOT NULL,
    Estado               CHAR(1)         NOT NULL,
    PRIMARY KEY (IdTipoComprobante)
)ENGINE=INNODB
;



-- 
-- TABLE: TiposComprobantesAfip 
--

CREATE TABLE TiposComprobantesAfip(
    IdTipoComprobanteAfip    SMALLINT        NOT NULL,
    TipoComprobanteAfip      VARCHAR(100),
    FechaDesde               DATE,
    FechaHasta               DATE,
    PRIMARY KEY (IdTipoComprobanteAfip)
)
;



-- 
-- TABLE: TiposDocAfip 
--

CREATE TABLE TiposDocAfip(
    IdTipoDocAfip    TINYINT         NOT NULL,
    TipoDocAfip      VARCHAR(100),
    FechaDesde       DATE,
    FechaHasta       DATE,
    PRIMARY KEY (IdTipoDocAfip)
)
;



-- 
-- TABLE: TiposIVA 
--

CREATE TABLE TiposIVA(
    IdTipoIVA     TINYINT           NOT NULL,
    TipoIVA       VARCHAR(25),
    Porcentaje    DECIMAL(12, 2),
    FechaDesde    DATE,
    FechaHasta    DATE,
    PRIMARY KEY (IdTipoIVA)
)
;



-- 
-- TABLE: TiposTributos 
--

CREATE TABLE TiposTributos(
    IdTipoTributo    TINYINT         NOT NULL,
    TipoTributo      VARCHAR(100),
    FechaDesde       DATE,
    FechaHasta       DATE,
    PRIMARY KEY (IdTipoTributo)
)
;



-- 
-- TABLE: Usuarios 
--

CREATE TABLE Usuarios(
    IdUsuario          BIGINT          NOT NULL,
    IdRol              INT             NOT NULL,
    Nombres            VARCHAR(30)     NOT NULL,
    Apellidos          VARCHAR(30)     NOT NULL,
    Usuario            VARCHAR(120)    NOT NULL,
    Password           VARCHAR(255)    NOT NULL,
    Token              VARCHAR(500)    NOT NULL,
    Email              VARCHAR(120)    NOT NULL,
    IntentosPass       TINYINT         NOT NULL,
    FechaUltIntento    DATETIME        NOT NULL,
    FechaAlta          DATETIME        NOT NULL,
    DebeCambiarPass    CHAR(1)         NOT NULL,
    Estado             CHAR(1)         NOT NULL,
    Observaciones      TEXT,
    IdEmpresa          INT             NOT NULL,
    PRIMARY KEY (IdUsuario)
)ENGINE=INNODB
;



-- 
-- TABLE: UsuariosPuntosVenta 
--

CREATE TABLE UsuariosPuntosVenta(
    IdUsuarioPuntoVenta    BIGINT     AUTO_INCREMENT,
    IdPuntoVenta           BIGINT     NOT NULL,
    IdUsuario              BIGINT     NOT NULL,
    Estado                 CHAR(1)    NOT NULL,
    PRIMARY KEY (IdUsuarioPuntoVenta)
)
;



-- 
-- TABLE: UsuariosPuntoVenta 
--

CREATE TABLE UsuariosPuntoVenta(
    IdUsuario       BIGINT     NOT NULL,
    IdPuntoVenta    BIGINT     NOT NULL,
    IdEmpresa       INT        NOT NULL,
    Estado          CHAR(1)    NOT NULL,
    PRIMARY KEY (IdUsuario, IdPuntoVenta, IdEmpresa)
)ENGINE=INNODB
;



-- 
-- TABLE: Ventas 
--

CREATE TABLE Ventas(
    IdVenta                  BIGINT            NOT NULL,
    IdPuntoVenta             BIGINT            NOT NULL,
    IdEmpresa                INT               NOT NULL,
    IdCliente                BIGINT            NOT NULL,
    IdUsuario                BIGINT            NOT NULL,
    IdTipoComprobanteAfip    SMALLINT          NOT NULL,
    IdTipoTributo            TINYINT           NOT NULL,
    IdCanal                  BIGINT            NOT NULL,
    Monto                    DECIMAL(12, 2),
    FechaAlta                DATETIME          NOT NULL,
    Estado                   CHAR(1)           NOT NULL,
    Observaciones            TEXT,
    PRIMARY KEY (IdVenta)
)ENGINE=INNODB
;


CREATE TABLE `ModelosReporte` (
  `IdModeloReporte` int(11) NOT NULL,
  `IdModeloReportePadre` int(11) DEFAULT NULL,
  `Reporte` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `NombreMenu` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Procedimiento` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `OrdenMenu` int(11) NOT NULL,
  `Estado` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Ayuda` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`IdModeloReporte`),
  UNIQUE KEY `UI_Reporte` (`Reporte`),
  UNIQUE KEY `UI_OrdenMenuIdModeloReportePadre` (`OrdenMenu`,`IdModeloReportePadre`),
  UNIQUE KEY `UI_Procedimiento` (`Procedimiento`),
  KEY `RefModelosReporte536` (`IdModeloReportePadre`),
  CONSTRAINT `RefModelosReporte536` FOREIGN KEY (`IdModeloReportePadre`) REFERENCES `ModelosReporte` (`IdModeloReporte`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `ParamsReportes` (
  `IdModeloReporte` int(11) NOT NULL,
  `NroParametro` tinyint(4) NOT NULL,
  `Parametro` varchar(70) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Tipo` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Etiqueta` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ValorDefecto` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ProcLlenado` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ListaTieneTodos` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `yiiRules` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `OrdenForm` tinyint(4) NOT NULL,
  `ToolTipText` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ProcDame` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ValorNoEsUsaComun` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`IdModeloReporte`,`NroParametro`),
  UNIQUE KEY `UI_ParametroIdModeloReporte` (`Parametro`,`IdModeloReporte`),
  UNIQUE KEY `UI_OrdenFormIdModeloReporte` (`OrdenForm`,`IdModeloReporte`),
  CONSTRAINT `RefModelosReporte537` FOREIGN KEY (`IdModeloReporte`) REFERENCES `ModelosReporte` (`IdModeloReporte`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `CuentasCorrientes` (
  `IdCuentaCorriente` bigint(20) NOT NULL AUTO_INCREMENT,
  `IdEntidad` bigint(20) NOT NULL,
  `Tipo` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Monto` decimal(12, 2) NOT NULL,
  `Observaciones` text NULL,
  PRIMARY KEY (`IdCuentaCorriente`),
  UNIQUE KEY `UI_IdEntidadTipo` (`IdEntidad`,`Tipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `HistorialCuentasCorrientes` (
  `IdHistorial` bigint(20) NOT NULL AUTO_INCREMENT,  
  `IdCuentaCorriente` bigint(20) NOT NULL,
  `Monto` decimal(12, 2) NOT NULL,
  `Motivo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Fecha` datetime NOT NULL,
  `Observaciones` text NULL,
  PRIMARY KEY (`IdHistorial`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 
-- INDEX: UI_Empresa 
--

CREATE UNIQUE INDEX UI_Empresa ON Empresas(Empresa)
;
-- 
-- INDEX: UI_URL 
--

CREATE UNIQUE INDEX UI_URL ON Empresas(URL)
;
-- 
-- INDEX: IX_FechaIngreso 
--

CREATE INDEX IX_FechaIngreso ON Ingresos(FechaAlta, IdEmpresa)
;
-- 
-- INDEX: UI_MedioPago 
--

CREATE UNIQUE INDEX UI_MedioPago ON MediosPago(MedioPago)
;
-- 
-- INDEX: UI_Modulo 
--

CREATE UNIQUE INDEX UI_Modulo ON Modulos(Modulo)
;
-- 
-- INDEX: UI_Parametro 
--

CREATE UNIQUE INDEX UI_Parametro ON Parametros(Parametro)
;
-- 
-- INDEX: UI_Permiso 
--

CREATE UNIQUE INDEX UI_Permiso ON Permisos(Permiso)
;
-- 
-- INDEX: UI_ProveedorEmpresa 
--

CREATE UNIQUE INDEX UI_ProveedorEmpresa ON Proveedores(Proveedor, IdEmpresa)
;
-- 
-- INDEX: UI_IdProveedor 
--

CREATE UNIQUE INDEX UI_IdProveedor ON Proveedores(IdProveedor)
;
-- 
-- INDEX: UI_IdPuntoVenta 
--

CREATE UNIQUE INDEX UI_IdPuntoVenta ON PuntosVenta(IdPuntoVenta)
;
-- 
-- INDEX: UI_PuntoVentaEmpresa 
--

CREATE UNIQUE INDEX UI_PuntoVentaEmpresa ON PuntosVenta(PuntoVenta, IdEmpresa)
;
-- 
-- INDEX: UI_RolEmpresa 
--

CREATE UNIQUE INDEX UI_RolEmpresa ON Roles(Rol, IdEmpresa)
;
-- 
-- INDEX: UI_Rol 
--

CREATE UNIQUE INDEX UI_Rol ON RolesGenericos(Rol)
;
-- 
-- INDEX: UI_Usuario 
--

CREATE UNIQUE INDEX UI_Usuario ON Usuarios(Usuario, IdEmpresa)
;
-- 
-- INDEX: UI_Email 
--

CREATE UNIQUE INDEX UI_Email ON Usuarios(Email, IdEmpresa)
;
-- 
-- INDEX: UI_IdUsuarioIdPuntoVenta 
--

CREATE UNIQUE INDEX UI_IdUsuarioIdPuntoVenta ON UsuariosPuntosVenta(IdUsuario, IdPuntoVenta)
;
-- 
-- INDEX: IX_FechaVenta 
--

CREATE INDEX IX_FechaVenta ON Ventas(FechaAlta, IdEmpresa)
;
-- 
-- TABLE: Articulos 
--

ALTER TABLE Articulos ADD CONSTRAINT RefTiposIVA121 
    FOREIGN KEY (IdTipoIVA)
    REFERENCES TiposIVA(IdTipoIVA)
;

ALTER TABLE Articulos ADD CONSTRAINT RefProveedores9 
    FOREIGN KEY (IdProveedor, IdEmpresa)
    REFERENCES Proveedores(IdProveedor, IdEmpresa)
;


-- 
-- TABLE: Bancos 
--

ALTER TABLE Bancos ADD CONSTRAINT RefEmpresas104 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: Canales 
--

ALTER TABLE Canales ADD CONSTRAINT RefEmpresas148 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: Cheques 
--

ALTER TABLE Cheques ADD CONSTRAINT RefBancos105 
    FOREIGN KEY (IdBanco)
    REFERENCES Bancos(IdBanco)
;

ALTER TABLE Cheques ADD CONSTRAINT RefClientes106 
    FOREIGN KEY (IdCliente)
    REFERENCES Clientes(IdCliente)
;

ALTER TABLE Cheques ADD CONSTRAINT RefDestinoCheque138 
    FOREIGN KEY (IdDestinoCheque)
    REFERENCES DestinoCheque(IdDestinoCheque)
;


-- 
-- TABLE: Clientes 
--

ALTER TABLE Clientes ADD CONSTRAINT RefListasPrecio107 
    FOREIGN KEY (IdListaPrecio)
    REFERENCES ListasPrecio(IdListaPrecio)
;

ALTER TABLE Clientes ADD CONSTRAINT RefTiposDocAfip122 
    FOREIGN KEY (IdTipoDocAfip)
    REFERENCES TiposDocAfip(IdTipoDocAfip)
;

ALTER TABLE Clientes ADD CONSTRAINT RefEmpresas40 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: Comprobantes 
--

ALTER TABLE Comprobantes ADD CONSTRAINT RefPagos108 
    FOREIGN KEY (IdPago)
    REFERENCES Pagos(IdPago)
;

ALTER TABLE Comprobantes ADD CONSTRAINT RefTiposComprobante53 
    FOREIGN KEY (IdTipoComprobante)
    REFERENCES TiposComprobante(IdTipoComprobante)
;


-- 
-- TABLE: DestinoCheque 
--

ALTER TABLE DestinoCheque ADD CONSTRAINT RefEmpresas139 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: ExistenciasConsolidadas 
--

ALTER TABLE ExistenciasConsolidadas ADD CONSTRAINT RefArticulos10 
    FOREIGN KEY (IdArticulo)
    REFERENCES Articulos(IdArticulo)
;

ALTER TABLE ExistenciasConsolidadas ADD CONSTRAINT RefPuntosVenta13 
    FOREIGN KEY (IdPuntoVenta)
    REFERENCES PuntosVenta(IdPuntoVenta)
;

ALTER TABLE ExistenciasConsolidadas ADD CONSTRAINT RefCanales149 
    FOREIGN KEY (IdCanal)
    REFERENCES Canales(IdCanal)
;


-- 
-- TABLE: HistorialDescuentos 
--

ALTER TABLE HistorialDescuentos ADD CONSTRAINT RefProveedores130 
    FOREIGN KEY (IdProveedor)
    REFERENCES Proveedores(IdProveedor)
;


-- 
-- TABLE: HistorialPorcentajes 
--

ALTER TABLE HistorialPorcentajes ADD CONSTRAINT RefListasPrecio131 
    FOREIGN KEY (IdListaPrecio)
    REFERENCES ListasPrecio(IdListaPrecio)
;


-- 
-- TABLE: HistorialPrecios 
--

ALTER TABLE HistorialPrecios ADD CONSTRAINT RefArticulos132 
    FOREIGN KEY (IdArticulo)
    REFERENCES Articulos(IdArticulo)
;

ALTER TABLE HistorialPrecios ADD CONSTRAINT RefPreciosArticulos134 
    FOREIGN KEY (IdArticulo, IdListaPrecio)
    REFERENCES PreciosArticulos(IdArticulo, IdListaPrecio)
;


-- 
-- TABLE: Ingresos 
--

ALTER TABLE Ingresos ADD CONSTRAINT RefPuntosVenta32 
    FOREIGN KEY (IdPuntoVenta, IdEmpresa)
    REFERENCES PuntosVenta(IdPuntoVenta, IdEmpresa)
;

ALTER TABLE Ingresos ADD CONSTRAINT RefClientes42 
    FOREIGN KEY (IdCliente)
    REFERENCES Clientes(IdCliente)
;

ALTER TABLE Ingresos ADD CONSTRAINT RefRemitos44 
    FOREIGN KEY (IdRemito)
    REFERENCES Remitos(IdRemito)
;

ALTER TABLE Ingresos ADD CONSTRAINT RefUsuarios48 
    FOREIGN KEY (IdUsuario)
    REFERENCES Usuarios(IdUsuario)
;


-- 
-- TABLE: LineasIngreso 
--

ALTER TABLE LineasIngreso ADD CONSTRAINT RefArticulos33 
    FOREIGN KEY (IdArticulo)
    REFERENCES Articulos(IdArticulo)
;

ALTER TABLE LineasIngreso ADD CONSTRAINT RefIngresos34 
    FOREIGN KEY (IdIngreso)
    REFERENCES Ingresos(IdIngreso)
;


-- 
-- TABLE: LineasVenta 
--

ALTER TABLE LineasVenta ADD CONSTRAINT RefVentas16 
    FOREIGN KEY (IdVenta)
    REFERENCES Ventas(IdVenta)
;

ALTER TABLE LineasVenta ADD CONSTRAINT RefArticulos25 
    FOREIGN KEY (IdArticulo)
    REFERENCES Articulos(IdArticulo)
;


-- 
-- TABLE: ListasPrecio 
--

ALTER TABLE ListasPrecio ADD CONSTRAINT RefEmpresas109 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: ModulosEmpresas 
--

ALTER TABLE ModulosEmpresas ADD CONSTRAINT RefModulos72 
    FOREIGN KEY (IdModulo)
    REFERENCES Modulos(IdModulo)
;

ALTER TABLE ModulosEmpresas ADD CONSTRAINT RefEmpresas73 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: Pagos 
--

ALTER TABLE Pagos ADD CONSTRAINT RefRemitos123 
    FOREIGN KEY (IdRemito)
    REFERENCES Remitos(IdRemito)
;

ALTER TABLE Pagos ADD CONSTRAINT RefCheques124 
    FOREIGN KEY (IdCheque)
    REFERENCES Cheques(IdCheque)
;

ALTER TABLE Pagos ADD CONSTRAINT RefVentas35 
    FOREIGN KEY (IdVenta)
    REFERENCES Ventas(IdVenta)
;

ALTER TABLE Pagos ADD CONSTRAINT RefMediosPago36 
    FOREIGN KEY (IdMedioPago)
    REFERENCES MediosPago(IdMedioPago)
;

ALTER TABLE Pagos ADD CONSTRAINT RefUsuarios49 
    FOREIGN KEY (IdUsuario)
    REFERENCES Usuarios(IdUsuario)
;


-- 
-- TABLE: ParametroEmpresa 
--

ALTER TABLE ParametroEmpresa ADD CONSTRAINT RefEmpresas74 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;

ALTER TABLE ParametroEmpresa ADD CONSTRAINT RefParametros75 
    FOREIGN KEY (Parametro, IdModulo)
    REFERENCES Parametros(Parametro, IdModulo)
;


-- 
-- TABLE: Parametros 
--

ALTER TABLE Parametros ADD CONSTRAINT RefModulos76 
    FOREIGN KEY (IdModulo)
    REFERENCES Modulos(IdModulo)
;


-- 
-- TABLE: Permisos 
--

ALTER TABLE Permisos ADD CONSTRAINT RefPermisos1 
    FOREIGN KEY (IdPermisoPadre)
    REFERENCES Permisos(IdPermiso)
;

ALTER TABLE Permisos ADD CONSTRAINT RefModulos77 
    FOREIGN KEY (IdModulo)
    REFERENCES Modulos(IdModulo)
;


-- 
-- TABLE: PermisosRol 
--

ALTER TABLE PermisosRol ADD CONSTRAINT RefPermisos4 
    FOREIGN KEY (IdPermiso)
    REFERENCES Permisos(IdPermiso)
;

ALTER TABLE PermisosRol ADD CONSTRAINT RefRoles5 
    FOREIGN KEY (IdRol)
    REFERENCES Roles(IdRol)
;


-- 
-- TABLE: PermisosRolGenerico 
--

ALTER TABLE PermisosRolGenerico ADD CONSTRAINT RefRolesGenericos78 
    FOREIGN KEY (IdRolGenerico)
    REFERENCES RolesGenericos(IdRolGenerico)
;

ALTER TABLE PermisosRolGenerico ADD CONSTRAINT RefPermisos79 
    FOREIGN KEY (IdPermiso)
    REFERENCES Permisos(IdPermiso)
;


-- 
-- TABLE: PreciosArticulos 
--

ALTER TABLE PreciosArticulos ADD CONSTRAINT RefListasPrecio110 
    FOREIGN KEY (IdListaPrecio)
    REFERENCES ListasPrecio(IdListaPrecio)
;

ALTER TABLE PreciosArticulos ADD CONSTRAINT RefArticulos111 
    FOREIGN KEY (IdArticulo)
    REFERENCES Articulos(IdArticulo)
;


-- 
-- TABLE: Proveedores 
--

ALTER TABLE Proveedores ADD CONSTRAINT RefEmpresas38 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: PuntosVenta 
--

ALTER TABLE PuntosVenta ADD CONSTRAINT RefEmpresas26 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: RectificacionesPV 
--

ALTER TABLE RectificacionesPV ADD CONSTRAINT RefPuntosVenta27 
    FOREIGN KEY (IdPuntoVentaOrigen, IdEmpresa)
    REFERENCES PuntosVenta(IdPuntoVenta, IdEmpresa)
;

ALTER TABLE RectificacionesPV ADD CONSTRAINT RefPuntosVenta28 
    FOREIGN KEY (IdPuntoVentaDestino, IdEmpresa)
    REFERENCES PuntosVenta(IdPuntoVenta, IdEmpresa)
;

ALTER TABLE RectificacionesPV ADD CONSTRAINT RefArticulos29 
    FOREIGN KEY (IdArticulo)
    REFERENCES Articulos(IdArticulo)
;

ALTER TABLE RectificacionesPV ADD CONSTRAINT RefUsuarios46 
    FOREIGN KEY (IdUsuario)
    REFERENCES Usuarios(IdUsuario)
;

ALTER TABLE RectificacionesPV ADD CONSTRAINT RefCanales150 
    FOREIGN KEY (IdCanal)
    REFERENCES Canales(IdCanal)
;


-- 
-- TABLE: Remitos 
--

ALTER TABLE Remitos ADD CONSTRAINT RefClientes112 
    FOREIGN KEY (IdCliente)
    REFERENCES Clientes(IdCliente)
;

ALTER TABLE Remitos ADD CONSTRAINT RefEmpresas113 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;

ALTER TABLE Remitos ADD CONSTRAINT RefProveedores43 
    FOREIGN KEY (IdProveedor)
    REFERENCES Proveedores(IdProveedor)
;

ALTER TABLE Remitos ADD CONSTRAINT RefCanales151 
    FOREIGN KEY (IdCanal)
    REFERENCES Canales(IdCanal)
;


-- 
-- TABLE: Roles 
--

ALTER TABLE Roles ADD CONSTRAINT RefEmpresas3 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: SesionesUsuarios 
--

ALTER TABLE SesionesUsuarios ADD CONSTRAINT RefUsuarios7 
    FOREIGN KEY (IdUsuario)
    REFERENCES Usuarios(IdUsuario)
;


-- 
-- TABLE: Usuarios 
--

ALTER TABLE Usuarios ADD CONSTRAINT RefRoles6 
    FOREIGN KEY (IdRol)
    REFERENCES Roles(IdRol)
;

ALTER TABLE Usuarios ADD CONSTRAINT RefEmpresas80 
    FOREIGN KEY (IdEmpresa)
    REFERENCES Empresas(IdEmpresa)
;


-- 
-- TABLE: UsuariosPuntosVenta 
--

ALTER TABLE UsuariosPuntosVenta ADD CONSTRAINT RefUsuarios88 
    FOREIGN KEY (IdUsuario)
    REFERENCES Usuarios(IdUsuario)
;

ALTER TABLE UsuariosPuntosVenta ADD CONSTRAINT RefPuntosVenta89 
    FOREIGN KEY (IdPuntoVenta)
    REFERENCES PuntosVenta(IdPuntoVenta)
;


-- 
-- TABLE: UsuariosPuntoVenta 
--

ALTER TABLE UsuariosPuntoVenta ADD CONSTRAINT RefUsuarios54 
    FOREIGN KEY (IdUsuario)
    REFERENCES Usuarios(IdUsuario)
;

ALTER TABLE UsuariosPuntoVenta ADD CONSTRAINT RefPuntosVenta55 
    FOREIGN KEY (IdPuntoVenta, IdEmpresa)
    REFERENCES PuntosVenta(IdPuntoVenta, IdEmpresa)
;


-- 
-- TABLE: Ventas 
--

ALTER TABLE Ventas ADD CONSTRAINT RefTiposComprobantesAfip125 
    FOREIGN KEY (IdTipoComprobanteAfip)
    REFERENCES TiposComprobantesAfip(IdTipoComprobanteAfip)
;

ALTER TABLE Ventas ADD CONSTRAINT RefTiposTributos126 
    FOREIGN KEY (IdTipoTributo)
    REFERENCES TiposTributos(IdTipoTributo)
;

ALTER TABLE Ventas ADD CONSTRAINT RefPuntosVenta24 
    FOREIGN KEY (IdPuntoVenta, IdEmpresa)
    REFERENCES PuntosVenta(IdPuntoVenta, IdEmpresa)
;

ALTER TABLE Ventas ADD CONSTRAINT RefClientes41 
    FOREIGN KEY (IdCliente)
    REFERENCES Clientes(IdCliente)
;

ALTER TABLE Ventas ADD CONSTRAINT RefUsuarios47 
    FOREIGN KEY (IdUsuario)
    REFERENCES Usuarios(IdUsuario)
;

ALTER TABLE Ventas ADD CONSTRAINT RefCanales152 
    FOREIGN KEY (IdCanal)
    REFERENCES Canales(IdCanal)
;


