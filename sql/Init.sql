-- Modulos del sistema
INSERT INTO Modulos VALUES (0, 'Empresas', 'A', 'Permite gestionar las empresas registradas en el sistema.');
INSERT INTO Modulos VALUES (1, 'Administrativo', 'A', 'Permite gestionar parámetros de empresa, roles y usuarios.');
INSERT INTO Modulos VALUES (2, 'Ventas', 'A', 'Permite gestionar artículos, proveedores y puntos de ventas.');

-- Tributos AFIP
INSERT INTO TiposTributos VALUES (1, 'Impuestos Nacionales', '2010-09-17', NULL);
INSERT INTO TiposTributos VALUES (2, 'Impuestos Provinciales', '2010-09-17', NULL);
INSERT INTO TiposTributos VALUES (3, 'Impuestos Municipales', '2010-09-17', NULL);
INSERT INTO TiposTributos VALUES (4, 'Impuestos Internos', '2010-09-17', NULL);
INSERT INTO TiposTributos VALUES (5, 'IIBB', '2017-07-19', NULL);
INSERT INTO TiposTributos VALUES (6, 'Percepción de IVA', '2017-07-19', NULL);
INSERT INTO TiposTributos VALUES (7, 'Percepción de IIBB', '2017-07-19', NULL);
INSERT INTO TiposTributos VALUES (8, 'Percepciones por Impuestos Municipales', '2017-07-19', NULL);
INSERT INTO TiposTributos VALUES (9, 'Otras Percepciones', '2017-07-19', NULL);
INSERT INTO TiposTributos VALUES (13, 'Percepción de IVA a no Categorizado', '2017-07-19', NULL);
INSERT INTO TiposTributos VALUES (99, 'Otro', '2010-09-17', NULL);

-- TiposDoc AFIP
INSERT INTO TiposDocAfip VALUES (80, 'CUIT', '2008-07-25', NULL);
INSERT INTO TiposDocAfip VALUES (86, 'CUIL', '2008-07-25', NULL);
INSERT INTO TiposDocAfip VALUES (96, 'DNI', '2008-07-25', NULL);
INSERT INTO TiposDocAfip VALUES (94, 'Pasaporte', '2008-07-25', NULL);

-- TiposIVA AFIP
INSERT INTO TiposIVA VALUES (3, '0%', 0, '2009-02-20', NULL);
INSERT INTO TiposIVA VALUES (4, '10.5%', 10.5, '2009-02-20', NULL);
INSERT INTO TiposIVA VALUES (5, '21%', 21, '2009-02-20', NULL);
INSERT INTO TiposIVA VALUES (6, '27%', 27, '2009-02-20', NULL);
INSERT INTO TiposIVA VALUES (8, '5%', 5, '2014-10-20', NULL);
INSERT INTO TiposIVA VALUES (9, '2.5%', 2.5, '2014-10-20', NULL);

-- TiposComprobante AFIP
INSERT INTO TiposComprobantesAfip VALUES("1", "Factura A", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("2", "Nota de Débito A", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("3", "Nota de Crédito A", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("6", "Factura B", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("7", "Nota de Débito B", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("8", "Nota de Crédito B", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("4", "Recibos A", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("5", "Notas de Venta al contado A", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("9", "Recibos B", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("10", "Notas de Venta al contado B", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("63", "Liquidacion A", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("64", "Liquidacion B", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("34", "Cbtes. A del Anexo I, Apartado A,inc.f),R.G.Nro. 1415", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("35", "Cbtes. B del Anexo I,Apartado A,inc. f),R.G. Nro. 1415", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("39", "Otros comprobantes A que cumplan con R.G.Nro. 1415", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("40", "Otros comprobantes B que cumplan con R.G.Nro. 1415", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("60", "Cta de Vta y Liquido prod. A", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("61", "Cta de Vta y Liquido prod. B", "2010-09-17", NULL);
INSERT INTO TiposComprobantesAfip VALUES("11", "Factura C", "2011-03-30", NULL);
INSERT INTO TiposComprobantesAfip VALUES("12", "Nota de Débito C", "2011-03-30", NULL);
INSERT INTO TiposComprobantesAfip VALUES("13", "Nota de Crédito C", "2011-03-30", NULL);
INSERT INTO TiposComprobantesAfip VALUES("15", "Recibo C", "2011-03-30", NULL);
INSERT INTO TiposComprobantesAfip VALUES("49", "Comprobante de Compra de Bienes Usados a Consumidor Final", "2013-04-01", NULL);
INSERT INTO TiposComprobantesAfip VALUES("51", "Factura M", "2015-05-22", NULL);
INSERT INTO TiposComprobantesAfip VALUES("52", "Nota de Débito M", "2015-05-22", NULL);
INSERT INTO TiposComprobantesAfip VALUES("53", "Nota de Crédito M", "2015-05-22", NULL);
INSERT INTO TiposComprobantesAfip VALUES("54", "Recibo M", "2015-05-22", NULL);
INSERT INTO TiposComprobantesAfip VALUES("201", "Factura de Crédito electrónica MiPyMEs (FCE) A", "2018-12-26", NULL);
INSERT INTO TiposComprobantesAfip VALUES("202", "Nota de Débito electrónica MiPyMEs (FCE) A", "2018-12-26", NULL);
INSERT INTO TiposComprobantesAfip VALUES("203", "Nota de Crédito electrónica MiPyMEs (FCE) A", "2018-12-26", NULL);
INSERT INTO TiposComprobantesAfip VALUES("206", "Factura de Crédito electrónica MiPyMEs (FCE) B", "2018-12-26", NULL);
INSERT INTO TiposComprobantesAfip VALUES("207", "Nota de Débito electrónica MiPyMEs (FCE) B", "2018-12-26", NULL);
INSERT INTO TiposComprobantesAfip VALUES("208", "Nota de Crédito electrónica MiPyMEs (FCE) B", "2018-12-26", NULL);
INSERT INTO TiposComprobantesAfip VALUES("211", "Factura de Crédito electrónica MiPyMEs (FCE) C", "2018-12-26", NULL);
INSERT INTO TiposComprobantesAfip VALUES("212", "Nota de Débito electrónica MiPyMEs (FCE) C", "2018-12-26", NULL);
INSERT INTO TiposComprobantesAfip VALUES("213", "Nota de Crédito electrónica MiPyMEs (FCE) C", "2018-12-26", NULL);



-- Parámetros de modulos
INSERT INTO Parametros VALUES('EMPRESA', 1, 'Nombre o razón social de la empresa para su uso en encabezados de página, informes, etc.', 'Cadena', 'SET @pValor = (SELECT Empresa FROM Empresas WHERE IdEmpresa = @pIdEmpresa);', 'S', 'S');
INSERT INTO Parametros VALUES('LOGO', 1, 'Indica la URL de la imagen del isologo.', 'Cadena', 'SET @pValor = "/img/brand/logo.svg";', 'S', 'S');
INSERT INTO Parametros VALUES('MAXINTPASS', 1, 'Cantidad máxima de intentos fallidos de inicio de sesión.', 'Entero', 'SET @pValor = 3;', 'S', 'S');
INSERT INTO Parametros VALUES('NUMPASSNOREPETIR', 1, 'Cantidad de últimas contraseñas que el sistema recordará y que el usuario no puede volver a repetir cuando cambie.', '2 a 15', 'SET @pValor = 3;', 'S', 'N');
INSERT INTO Parametros VALUES('CANTFILASPAGINADO', 1, 'Indica la cantidad de filas por página de un conjunto de registros. P. ej. paginación de búsquedas.', 'Entero', 'SET @pValor = 20;', 'S', 'S');
INSERT INTO Parametros VALUES('CORREONOTIFICACIONES', 1, 'Es el correo electrónico de la empresa usado para notificaciones.', 'Cadena', 'SET @pValor = (SELECT CONCAT(SUBSTRING_INDEX(URL, ".", 1), "@forta.xyz") FROM Empresas WHERE IdEmpresa = @pIdEmpresa);', 'S', 'S');
INSERT INTO Parametros VALUES('CUIT', 1, 'Indica la Clave Única de Identificación Tributaria de la empresa.', 'Entero', 'SET @pValor = 30101001003;', 'S', 'N');
INSERT INTO Parametros VALUES('ROLVENDEDOR', 1, 'Nombre del Rol Vendedor.', 'Cadena', 'SET @pValor = "Vendedor";', 'S', 'N');
INSERT INTO Parametros VALUES('MAXTIEMPOANULACION', 2, 'Máximo tiempo en minutos para anular una venta, pago, ingreso o rectificación.', 'Entero', 'SET @pValor = 30;', 'S', 'N');
INSERT INTO Parametros VALUES('AFIPCERT', 1, 'Certificado AFIP WS.', 'Cadena', 'SET @pValor = "";', 'S', 'S');
INSERT INTO Parametros VALUES('AFIPCERTHOMO', 1, 'Certificado AFIP WS.', 'Cadena', 'SET @pValor = "";', 'S', 'S');
INSERT INTO Parametros VALUES('AFIPMODOHOMO', 1, 'Afip en modo homologación', 'Cadena', 'SET @pValor = "";', 'S', 'S');
INSERT INTO Parametros VALUES('AFIPKEY', 1, 'Clave AFIP WS.', 'Cadena', 'SET @pValor = "";', 'S', 'S');
INSERT INTO Parametros VALUES('PROVINCIA', 1, 'Provincia por defecto en la cual se cargarán los clientes.', 'Cadena', 'SET @pValor = "";', 'S', 'S');
INSERT INTO Parametros VALUES('CANTCANALES', 1, 'Indica la cantidad de canales disponibles para el stock. De ser 1 deshabilita las vistas e inputs referentes a canales.', 'Entero', 'SET @pValor = 1;', 'N', 'S');
INSERT INTO Parametros VALUES('CANALPORDEFECTO', 1, 'Id del canal por defecto de una empresa.', 'Entero', 'SET @pValor = 0;', 'N', 'S');
INSERT INTO Parametros VALUES('NUMEROCOMPROBANTE', 1, 'Numero de Comprobante de Afip del proximo comprobante. Se calcula al insertar un nuevo comprobante.', 'Entero', 'SET @pValor = 1;', 'N', 'S');
INSERT INTO Parametros VALUES('LISTAPORDEFECTO', 1, 'Id de la lista por defecto de una empresa.', 'Entero', 'SET @pValor = 0;', 'N', 'S');

-- Agrego empresa propia
INSERT INTO Empresas VALUES (1, 'GestionX', 'backend.127.0.0.1.xip.io:5000', 'A');

-- Agrego módulos a empresa
INSERT INTO ModulosEmpresas VALUES (1, 0), (1, 1), (1, 2);

-- Permisos de los módulos
INSERT INTO Permisos VALUES (1, NULL, 'Sistema', 'Permisos de Sistema', 'A', NULL, 1, NULL, 1);

INSERT INTO Permisos VALUES(55,1,'Autoriza', 'Puede autorizar una operación','A',NULL,2,NULL, 1);

INSERT INTO Permisos VALUES (2,1,'GestionParametros','Gestionar Parámetros de la Empresa','A',NULL,3,NULL, 1);
	INSERT INTO Permisos VALUES (3,2,'BuscarParametro','Buscar y Listar Parámetros','A',NULL,1,'xsp_buscar_parametros', 1);
	INSERT INTO Permisos VALUES (4,2,'ModificarParametro','Modificar Parámetros','A',NULL,2,'xsp_cambiar_parametro', 1);

INSERT INTO Permisos VALUES (5,1,'GestionRoles','Gestionar Roles de Usuarios','A',NULL,4,NULL, 1);
	INSERT INTO Permisos VALUES (6,5,'BuscarRoles','Buscar y Listar Roles','A',NULL,1,'xsp_buscar_roles', 1);
	INSERT INTO Permisos VALUES (7,5,'AltaRol','Crear Roles','A',NULL,2,'xsp_alta_rol', 1);
	INSERT INTO Permisos VALUES (8,5,'ModificarRol','Modificar Roles','A',NULL,3,'xsp_modifica_rol', 1);
	INSERT INTO Permisos VALUES (9,5,'BorrarRol','Borrar Roles','A',NULL,4,'xsp_borra_rol', 1);
	INSERT INTO Permisos VALUES (10,5,'DarBajaRol','Dar de Baja Roles','A',NULL,5,'xsp_darbaja_rol', 1);
	INSERT INTO Permisos VALUES (11,5,'ActivarRol','Activar Roles','A',NULL,6,'xsp_activar_rol', 1);
	INSERT INTO Permisos VALUES (12,5,'ClonarRol','Clonar Roles','A',NULL,7,'xsp_clonar_rol', 1);
	INSERT INTO Permisos VALUES (13,5,'ListarPermisosRol','Ver Permisos de Roles','A',NULL,8,'xsp_listar_permisos_rol', 1);
	INSERT INTO Permisos VALUES (14,5,'AsignarPermisosRol','Asignar y Quitar Permisos de Roles','A',NULL,9,'xsp_asignar_permisos_rol', 1);

INSERT INTO Permisos VALUES(15,1,'GestionUsuarios', 'Gestión de Usuarios','A',NULL,5,NULL, 1);
	INSERT INTO Permisos VALUES(16,15, 'AltaUsuario', 'Crear usuarios', 'A', NULL, '1', 'xsp_alta_usuario', 1);
	INSERT INTO Permisos VALUES(17,15, 'ModificarUsuario', 'Modificar usuarios', 'A', NULL, '2', 'xsp_modifica_usuario', 1);
	INSERT INTO Permisos VALUES(18,15, 'BorrarUsuario', 'Borrar usuarios', 'A', NULL, '3', 'xsp_borra_usuario', 1);
	INSERT INTO Permisos VALUES(19,15, 'BuscarUsuarios', 'Buscar usuarios', 'A', NULL, '4', 'xsp_buscar_usuarios', 1);
	INSERT INTO Permisos VALUES(20,15, 'ActivarUsuario', 'Activar usuarios', 'A', NULL, '5', 'xsp_activar_usuario', 1);
	INSERT INTO Permisos VALUES(21,15, 'DarBajaUsuario', 'Dar de baja usuarios', 'A', NULL, '6', 'xsp_darbaja_usuario', 1);
	INSERT INTO Permisos VALUES(24,15, 'RestablecerPassword', 'Restablecer contraseña de un usuario', 'A', NULL, '7', 'xsp_restablecer_password', 1);

INSERT INTO Permisos VALUES(22,1,'GestionEmpresas', 'Gestión de Empresas','A',NULL,6,NULL, 0);
	INSERT INTO Permisos VALUES(58,22, 'BuscarEmpresas', 'Buscar empresas', 'A', NULL, '1', NULL, 0);
	INSERT INTO Permisos VALUES(23,22, 'AltaEmpresa', 'Crear empresas', 'A', NULL, '1', 'xsp_alta_empresa', 0);
	INSERT INTO Permisos VALUES(56,22, 'ActivarEmpresa', 'Activar empresas', 'A', NULL, '2', 'xsp_activar_empresa', 0);
	INSERT INTO Permisos VALUES(57,22, 'DarBajaEmpresa', 'Dar de baja empresas', 'A', NULL, '3', 'xsp_darbaja_empresa', 0);

INSERT INTO Permisos VALUES(25,1,'GestionProveedores', 'Gestión de Proveedores','A',NULL,7,NULL, 2);
	INSERT INTO Permisos VALUES(26,25, 'AltaProveedor', 'Dar de alta proveedores', 'A', NULL, '1', 'xsp_alta_proveedor', 2);
	INSERT INTO Permisos VALUES(27,25, 'ModificarProveedor', 'Modificar proveedores', 'A', NULL, '2', 'xsp_modifica_proveedor', 2);
	INSERT INTO Permisos VALUES(28,25, 'BorrarProveedor', 'Borrar proveedores', 'A', NULL, '3', 'xsp_borra_proveedor', 2);
	INSERT INTO Permisos VALUES(29,25, 'BuscarProveedores', 'Buscar proveedores', 'A', NULL, '4', 'xsp_buscar_proveedores', 2);
	INSERT INTO Permisos VALUES(30,25, 'ActivarProveedor', 'Activar proveedores', 'A', NULL, '5', 'xsp_activar_proveedor', 2);
	INSERT INTO Permisos VALUES(31,25, 'DarBajaProveedor', 'Dar de baja proveedores', 'A', NULL, '6', 'xsp_darbaja_proveedor', 2);
	INSERT INTO Permisos VALUES(122,25, 'ListarHistorialDescuentosProveedor', 'Lista el historial de descuentos de proveedores', 'A', NULL, '7', 'xsp_listar_historial_proveedor', 2);
	INSERT INTO Permisos VALUES(152,25, 'PagarProveedor', 'Pagar a un proveedor','A',NULL,'8',NULL, 2);
		INSERT INTO Permisos VALUES(153,152, 'PagarProveedorEfectivo', 'Pagar a un proveedor, con efectivo','A',NULL,'1','xsp_pagar_proveedor_efectivo', 2);
		INSERT INTO Permisos VALUES(154,152, 'PagarProveedorCheque', 'Pagar a un proveedor, con cheques','A',NULL,'2','xsp_pagar_proveedor_cheque', 2);
		INSERT INTO Permisos VALUES(155,152, 'PagarProveedorTarjeta', 'Pagar a un proveedor, con tarjeta','A',NULL,'3','xsp_pagar_proveedor_tarjeta', 2);
		INSERT INTO Permisos VALUES(156,152, 'PagarProveedorRetencion', 'Pagar a un proveedor, de tipo rentencion','A',NULL,'4','xsp_pagar_proveedor_retencion', 2);
		INSERT INTO Permisos VALUES(157,152, 'ModificarPagoProveedorEfectivo', 'Modificar pagos a proveedores, con efectivo','A',NULL,'5','xsp_modificar_pago_proveedor_efectivo', 2);
		INSERT INTO Permisos VALUES(158,152, 'ModificarPagoProveedorCheque', 'Modificar pagos a proveedores, con cheques','A',NULL,'6','xsp_modificar_pago_proveedor_cheque', 2);
		INSERT INTO Permisos VALUES(159,152, 'ModificarPagoProveedorTarjeta', 'Modificar pagos a proveedores, con tarjeta','A',NULL,'7','xsp_modificar_pago_proveedor_tarjeta', 2);
		INSERT INTO Permisos VALUES(160,152, 'ModificarPagoProveedorRetencion', 'Modificar pagos a proveedores, de tipo rentencion','A',NULL,'8','xsp_modificar_pago_proveedor_retencion', 2);
		INSERT INTO Permisos VALUES(161,152, 'BorrarPagoProveedor', 'Borrar pagos a un proveedor','A',NULL,'9','xsp_borrar_pago_proveedor', 2);
		INSERT INTO Permisos VALUES(173,152, 'BuscarPagosProveedor', 'Buscar pagos de un proveedor', 'A', NULL, '10', 'xsp_buscar_pagos_proveedor', 2);

INSERT INTO Permisos VALUES(32,1,'GestionArticulos', 'Gestión de Articulos','A',NULL,8,NULL, 2);
	INSERT INTO Permisos VALUES(33,32, 'AltaArticulo', 'Dar de alta articulos', 'A', NULL, '1', 'xsp_alta_articulo', 2);
	INSERT INTO Permisos VALUES(34,32, 'ModificarArticulo', 'Modificar articulos', 'A', NULL, '2', 'xsp_modifica_articulo', 2);
	INSERT INTO Permisos VALUES(35,32, 'BorrarArticulo', 'Borrar articulos', 'A', NULL, '3', 'xsp_borra_articulo', 2);
	INSERT INTO Permisos VALUES(36,32, 'BuscarArticulos', 'Buscar articulos', 'A', NULL, '4', 'xsp_buscar_articulos', 2);
	INSERT INTO Permisos VALUES(37,32, 'ActivarArticulo', 'Activar articulos', 'A', NULL, '5', 'xsp_activar_articulo', 2);
	INSERT INTO Permisos VALUES(38,32, 'DarBajaArticulo', 'Dar de baja articulos', 'A', NULL, '6', 'xsp_darbaja_articulo', 2);
	INSERT INTO Permisos VALUES(123,32, 'ListarHistorialPreciosArticulo', 'Lista el historial de precios de articulos', 'A', NULL, '7', 'xsp_listar_historial_articulo', 2);
	INSERT INTO Permisos VALUES(137,32, 'VerPrecioArticulo', 'Ver el precio de costo de un articulo', 'A', NULL, '8', 'xsp_buscar_articulos', 2);

INSERT INTO Permisos VALUES(39,1,'GestionPuntosVenta', 'Gestión de Puntos de venta','A',NULL,9,NULL, 2);
	INSERT INTO Permisos VALUES(40,39, 'AltaPuntoVenta', 'Dar de alta puntos de venta', 'A', NULL, '1', 'xsp_alta_puntoventa', 2);
	INSERT INTO Permisos VALUES(41,39, 'ModificarPuntoVenta', 'Modificar puntos de venta', 'A', NULL, '2', 'xsp_modifica_puntoventa', 2);
	INSERT INTO Permisos VALUES(42,39, 'BorrarPuntoVenta', 'Borrar puntos de venta', 'A', NULL, '3', 'xsp_borra_puntoventa', 2);
	INSERT INTO Permisos VALUES(43,39, 'BuscarPuntosVenta', 'Buscar puntos de venta', 'A', NULL, '4', 'xsp_buscar_puntosventa', 2);
	INSERT INTO Permisos VALUES(44,39, 'ActivarPuntoVenta', 'Activar puntos de venta', 'A', NULL, '5', 'xsp_activar_puntoventa', 2);
	INSERT INTO Permisos VALUES(45,39, 'DarBajaPuntoVenta', 'Dar de baja puntos de venta', 'A', NULL, '6', 'xsp_darbaja_puntoventa', 2);
	INSERT INTO Permisos VALUES(72,39, 'BuscarUsuariosPuntoVenta', 'Buscar usuarios de puntos de venta', 'A', NULL, '7', 'xsp_buscar_usuarios_puntosventa', 2);
	INSERT INTO Permisos VALUES(73,39, 'AsignarUsuarioPuntoVenta', 'Asignar usuarios a puntos de venta', 'A', NULL, '8', 'xsp_asignar_usuario_puntoventa', 2);
	INSERT INTO Permisos VALUES(74,39, 'DesasignarUsuarioPuntoVenta', 'Desasignar usuarios de puntos de venta', 'A', NULL, '9', 'xsp_desasignar_usuario_puntoventa', 2);
	INSERT INTO Permisos VALUES(116,39, 'GestionRectificaciones', 'Gestión de Rectificaciones', 'A', NULL, '10', NULL, 2);
		INSERT INTO Permisos VALUES(117,116, 'AltaRectificacion', 'Dar de alta rectificaciones de puntos de venta', 'A', NULL, '1', 'xsp_alta_rectificacionpv', 2);
		INSERT INTO Permisos VALUES(118,116, 'BorrarRectificacion', 'Borrar rectificaciones de puntos de venta', 'A', NULL, '2', 'xsp_borra_rectificacionpv', 2);
		INSERT INTO Permisos VALUES(119,116, 'BuscarRectificacion', 'Buscar rectificaciones de puntos de venta', 'A', NULL, '3', 'xsp_buscar_rectificacionespv', 2);
		INSERT INTO Permisos VALUES(120,116, 'ConfirmarRectificacion', 'Confimar rectificaciones de puntos de venta', 'A', NULL, '4', 'xsp_confirmar_rectificacionpv', 2);
		INSERT INTO Permisos VALUES(121,116, 'DevolucionRectificacion', 'Devuelve rectificaciones de puntos de venta', 'A', NULL, '5', 'xsp_devolucion_rectificacionpv', 2);

INSERT INTO Permisos VALUES(46,1,'GestionRemitos', 'Gestión de Remitos','A',NULL,10,NULL, 2);
	INSERT INTO Permisos VALUES(47,46, 'AltaRemito', 'Dar de alta remitos', 'A', NULL, '1', 'xsp_alta_remito', 2);
	INSERT INTO Permisos VALUES(48,46, 'ModificarRemito', 'Modificar remitos', 'A', NULL, '2', 'xsp_modifica_remito', 2);
	INSERT INTO Permisos VALUES(49,46, 'BuscarRemitos', 'Buscar remitos', 'A', NULL, '3', 'xsp_buscar_remitos', 2);
	INSERT INTO Permisos VALUES(50,46, 'ActivarRemito', 'Activar remitos', 'A', NULL, '4', 'xsp_activar_remito', 2);
	INSERT INTO Permisos VALUES(51,46, 'DarBajaRemito', 'Dar de baja remitos', 'A', NULL, '5', 'xsp_darbaja_remito', 2);
	INSERT INTO Permisos VALUES(174,46, 'IngresarRemito', 'Ingresa remitos', 'A', NULL, '6', 'xsp_ingresar_remito', 2);


INSERT INTO Permisos VALUES(52,1,'GestionExistencias', 'Gestión de Existencias','A',NULL,11,NULL, 2);
	INSERT INTO Permisos VALUES(53,52,'AltaLineaExistencia', 'Dar de alta líneas de existencias','A',NULL,'1','xsp_alta_linea_existencia', 2);
	INSERT INTO Permisos VALUES(54,52,'BorrarLineaExistencia', 'Quitar líneas de existencias','A',NULL,'2','xsp_borrar_linea_existencia', 2);
	INSERT INTO Permisos VALUES(175,52,'ModificarLineaExistencia', 'Modificar líneas de existencias','A',NULL,'3','xsp_modificar_linea_existencia', 2);

INSERT INTO Permisos VALUES(59,1,'GestionTiposGravamenes', 'Gestión de Tipos de Gravamenes','A',NULL,12,NULL, 2);
	INSERT INTO Permisos VALUES(60,59, 'AltaTipoGravamen', 'Dar de alta tipos de gravamenes', 'A', NULL, '1', 'xsp_alta_tipogravamen', 2);
	INSERT INTO Permisos VALUES(61,59, 'ModificarTipoGravamen', 'Modificar tipos de gravamenes', 'A', NULL, '2', 'xsp_modifica_tipogravamen', 2);
	INSERT INTO Permisos VALUES(62,59, 'BuscarTiposGravamenes', 'Buscar tipos de gravamenes', 'A', NULL, '3', 'xsp_buscar_tiposgravamenes', 2);
	INSERT INTO Permisos VALUES(63,59, 'DarBajaTipoGravamen', 'Dar de baja tipos de gravamenes', 'A', NULL, '4', 'xsp_darbaja_tipogravamen', 2);
	
	INSERT INTO Permisos VALUES(64,32, 'ListarGravamenes', 'Listar Gravamenes de un Articulos', 'A', NULL, '7', 'xsp_listar_gravamenes', 2);
	
INSERT INTO Permisos VALUES(65,1,'GestionClientes', 'Gestión de Clientes','A',NULL,13,NULL, 2);
	INSERT INTO Permisos VALUES(66,65, 'AltaCliente', 'Dar de alta clientes', 'A', NULL, '1', 'xsp_alta_cliente', 2);
	INSERT INTO Permisos VALUES(67,65, 'ModificarCliente', 'Modificar clientes', 'A', NULL, '2', 'xsp_modifica_cliente', 2);
	INSERT INTO Permisos VALUES(68,65, 'BorrarCliente', 'Borrar clientes', 'A', NULL, '3', 'xsp_borra_cliente', 2);
	INSERT INTO Permisos VALUES(69,65, 'BuscarClientes', 'Buscar clientes', 'A', NULL, '4', 'xsp_buscar_clientes', 2);
	INSERT INTO Permisos VALUES(70,65, 'ActivarCliente', 'Activar clientes', 'A', NULL, '5', 'xsp_activar_cliente', 2);
	INSERT INTO Permisos VALUES(71,65, 'DarBajaCliente', 'Dar de baja clientes', 'A', NULL, '6', 'xsp_darbaja_cliente', 2);
	INSERT INTO Permisos VALUES(145,65, 'BuscarVentasClientes', 'Buscar ventas de clientes', 'A', NULL, '7', 'xsp_buscar_ventas_clientes', 2);
	INSERT INTO Permisos VALUES(162,65, 'PagarCliente', 'Recibir pagos de un Cliente','A',NULL,'8',NULL, 2);
		INSERT INTO Permisos VALUES(163,162, 'PagarClienteEfectivo', 'Recibir un pago de Cliente en efectivo','A',NULL,'1','xsp_pagar_cliente_efectivo', 2);
		INSERT INTO Permisos VALUES(164,162, 'PagarClienteCheque', 'Recibir un pago de Cliente en cheque','A',NULL,'2','xsp_pagar_cliente_cheque', 2);
		INSERT INTO Permisos VALUES(165,162, 'PagarClienteTarjeta', 'Recibir un pago de Cliente en tarjeta','A',NULL,'3','xsp_pagar_cliente_tarjeta', 2);
		INSERT INTO Permisos VALUES(166,162, 'PagarClienteRetencion', 'Recibir un pago de Cliente de tipo rentencion','A',NULL,'4','xsp_pagar_cliente_retencion', 2);
		INSERT INTO Permisos VALUES(167,162, 'ModificarPagoClienteEfectivo', 'Modificar pagos de clientes, de efectivo','A',NULL,'5','xsp_modificar_pago_cliente_efectivo', 2);
		INSERT INTO Permisos VALUES(168,162, 'ModificarPagoClienteCheque', 'Modificar pagos de clientes, de cheque','A',NULL,'6','xsp_modificar_pago_cliente_cheque', 2);
		INSERT INTO Permisos VALUES(169,162, 'ModificarPagoClienteTarjeta', 'Modificar pagos de clientes, de tarjeta','A',NULL,'7','xsp_modificar_pago_cliente_tarjeta', 2);
		INSERT INTO Permisos VALUES(170,162, 'ModificarPagoClienteRetencion', 'Modificar pagos de clientes, de tipo rentencion','A',NULL,'8','xsp_modificar_pago_cliente_retencion', 2);
		INSERT INTO Permisos VALUES(171,162, 'BorrarPagoCliente', 'Borrar pagos de clientes','A',NULL,'9','xsp_borrar_pago_cliente', 2);
		INSERT INTO Permisos VALUES(172,162, 'BuscarPagosClientes', 'Buscar pagos de un cliente', 'A', NULL, '10', 'xsp_buscar_pagos_cliente', 2);
	
INSERT INTO Permisos VALUES(75,1,'GestionVentas', 'Gestión de Ventas','A',NULL,14,NULL, 2);
	INSERT INTO Permisos VALUES(76,75, 'AltaVenta', 'Dar de alta ventas', 'A', NULL, '1', 'xsp_alta_venta', 2);
	INSERT INTO Permisos VALUES(77,75, 'ModificarVenta', 'Modificar ventas', 'A', NULL, '2', 'xsp_modifica_venta', 2);
	INSERT INTO Permisos VALUES(78,75, 'BorrarVenta', 'Borrar ventas', 'A', NULL, '3', 'xsp_borra_venta', 2);
	INSERT INTO Permisos VALUES(79,75, 'BuscarVentas', 'Buscar ventas', 'A', NULL, '4', 'xsp_buscar_ventas', 2);
	INSERT INTO Permisos VALUES(80,75, 'ActivarVenta', 'Activar ventas', 'A', NULL, '5', 'xsp_activar_venta', 2);
	INSERT INTO Permisos VALUES(81,75, 'DarBajaVenta', 'Dar de baja ventas', 'A', NULL, '6', 'xsp_darbaja_venta', 2);
	INSERT INTO Permisos VALUES(82,75, 'AltaLineaVenta', 'Dar de alta líneas de ventas', 'A', NULL, '7', 'xsp_alta_linea_venta', 2);
	INSERT INTO Permisos VALUES(83,75, 'BorrarLineaVenta', 'Quitar líneas de ventas','A',NULL,'8','xsp_borrar_linea_venta', 2);
	INSERT INTO Permisos VALUES(84,75, 'DevolucionVenta', 'Dar de baja ventas ya activas, devolviendo las existencias al punto d venta','A',NULL,'9','xsp_devolucion_venta', 2);
	INSERT INTO Permisos VALUES(100,75, 'PagarVenta', 'Pagar ventas ya activas','A',NULL,'10','xsp_pagar_venta', 2);
		INSERT INTO Permisos VALUES(101,100, 'PagarVentaCheque', 'Pagar ventas ya activas, con cheques','A',NULL,'1','xsp_pagar_venta_cheque', 2);
		INSERT INTO Permisos VALUES(102,100, 'PagarVentaEfectivo', 'Pagar ventas ya activas, con efectivo','A',NULL,'2','xsp_pagar_venta_efectivo', 2);
		INSERT INTO Permisos VALUES(103,100, 'PagarVentaTarjeta', 'Pagar ventas ya activas, con tarjeta','A',NULL,'3','xsp_pagar_venta_tarjeta', 2);
		INSERT INTO Permisos VALUES(104,100, 'PagarVentaMercaderia', 'Pagar ventas ya activas, con mercaderia','A',NULL,'4','xsp_pagar_venta_mercaderia', 2);
		INSERT INTO Permisos VALUES(105,100, 'BorrarPagoVenta', 'Borrar pagos de una venta','A',NULL,'5','xsp_borrar_pago_venta', 2);
		INSERT INTO Permisos VALUES(106,100, 'ModificarPagoVentaCheque', 'Modificar pagos, con cheques','A',NULL,'6','xsp_modificar_pago_cheque', 2);
		INSERT INTO Permisos VALUES(107,100, 'ModificarPagoVentaEfectivo', 'Modificar pagos, con efectivo','A',NULL,'7','xsp_modificar_pago_efectivo', 2);
		INSERT INTO Permisos VALUES(108,100, 'ModificarPagoVentaTarjeta', 'Modificar pagos, con tarjeta','A',NULL,'8','xsp_modificar_pago_tarjeta', 2);
		INSERT INTO Permisos VALUES(109,100, 'ModificarPagoVentaMercaderia', 'Modificar pagos, con mercaderia','A',NULL,'9','xsp_modificar_pago_mercaderia', 2);
		INSERT INTO Permisos VALUES(150,100, 'PagarVentaRetencion', 'Pagar ventas ya activas, de tipo rentencion','A',NULL,'10','xsp_pagar_venta_retencion', 2);
		INSERT INTO Permisos VALUES(151,100, 'ModificarPagoVentaRetencion', 'Modificar pagos, de tipo rentencion','A',NULL,'11','xsp_modificar_pago_retencion', 2);

INSERT INTO Permisos VALUES(85,1,'GestionBancos', 'Gestión de Bancos','A',NULL,15,NULL, 2);
	INSERT INTO Permisos VALUES(86,85, 'AltaBanco', 'Dar de alta bancos', 'A', NULL, '1', 'xsp_alta_banco', 2);
	INSERT INTO Permisos VALUES(87,85, 'ModificarBanco', 'Modificar bancos', 'A', NULL, '2', 'xsp_modifica_banco', 2);
	INSERT INTO Permisos VALUES(88,85, 'BorrarBanco', 'Borrar bancos', 'A', NULL, '3', 'xsp_borra_banco', 2);
	INSERT INTO Permisos VALUES(89,85, 'BuscarBancos', 'Buscar bancos', 'A', NULL, '4', 'xsp_buscar_bancos', 2);
	INSERT INTO Permisos VALUES(90,85, 'ActivarBanco', 'Activar bancos', 'A', NULL, '5', 'xsp_activar_banco', 2);
	INSERT INTO Permisos VALUES(91,85, 'DarBajaBanco', 'Dar de baja bancos', 'A', NULL, '6', 'xsp_darbaja_banco', 2);

INSERT INTO Permisos VALUES(92,1,'GestionCheques', 'Gestión de Cheques','A',NULL,16,NULL, 2);
	INSERT INTO Permisos VALUES(93,92, 'AltaChequeCliente', 'Dar de alta cheques de cliente', 'A', NULL, '1', 'xsp_alta_cheque', 2);
	INSERT INTO Permisos VALUES(94,92, 'AltaChequePropio', 'Dar de alta cheques propios', 'A', NULL, '2', 'xsp_alta_cheque', 2);
	INSERT INTO Permisos VALUES(95,92, 'ModificarChequePropio', 'Modificar cheques', 'A', NULL, '3', 'xsp_modifica_cheque', 2);
	INSERT INTO Permisos VALUES(96,92, 'BorrarChequePropio', 'Borrar cheques', 'A', NULL, '4', 'xsp_borra_cheque', 2);
	INSERT INTO Permisos VALUES(97,92, 'BuscarChequesPropios', 'Buscar cheques', 'A', NULL, '5', 'xsp_buscar_cheques', 2);
	INSERT INTO Permisos VALUES(98,92, 'ActivarChequePropio', 'Activar cheques', 'A', NULL, '6', 'xsp_activar_cheque', 2);
	INSERT INTO Permisos VALUES(99,92, 'DarBajaChequePropio', 'Dar de baja cheques', 'A', NULL, '7', 'xsp_darbaja_cheque', 2);
	INSERT INTO Permisos VALUES(132,92, 'ModificarChequeCliente', 'Modificar cheques de clientes', 'A', NULL, '8', 'xsp_modifica_cheque', 2);
	INSERT INTO Permisos VALUES(133,92, 'BorrarChequeCliente', 'Borrar cheques de clientes', 'A', NULL, '9', 'xsp_borra_cheque', 2);
	INSERT INTO Permisos VALUES(134,92, 'ActivarChequeCliente', 'Activar cheques de clientes', 'A', NULL, '10', 'xsp_activar_cheque', 2);
	INSERT INTO Permisos VALUES(135,92, 'DarBajaChequeCliente', 'Dar de baja cheques de clientes', 'A', NULL, '11', 'xsp_darbaja_cheque', 2);
	INSERT INTO Permisos VALUES(136,92, 'BuscarChequesClientes', 'Buscar cheques de clientes', 'A', NULL, '12', 'xsp_buscar_cheques', 2);
	

INSERT INTO Permisos VALUES(110,1,'GestionListasPrecio', 'Gestión de Listas de Precios','A',NULL,13,NULL, 2);
	INSERT INTO Permisos VALUES(111,110, 'AltaListaPrecio', 'Dar de alta listas de precios', 'A', NULL, '1', 'xsp_alta_lista_precio', 2);
	INSERT INTO Permisos VALUES(112,110, 'ModificarListaPrecio', 'Modificar listas de precios', 'A', NULL, '2', 'xsp_modifica_lista_precio', 2);
	INSERT INTO Permisos VALUES(113,110, 'BorrarListaPrecio', 'Borrar listas de precios', 'A', NULL, '3', 'xsp_borra_lista_precio', 2);
	INSERT INTO Permisos VALUES(114,110, 'BuscarListasPrecio', 'Buscar listas de precios', 'A', NULL, '4', 'xsp_buscar_listas_precio', 2);
	INSERT INTO Permisos VALUES(115,110, 'ActivarListaPrecio', 'Activar listas de precios', 'A', NULL, '5', 'xsp_activar_lista_precio', 2);
	INSERT INTO Permisos VALUES(124,110, 'ListarHistorialPorcentajesListaPrecio', 'Lista el historial de porcentajes de listas de precio', 'A', NULL, '6', 'xsp_listar_historial_lista_precio', 2);

INSERT INTO Permisos VALUES(125,1,'GestionDestinosCheque', 'Gestión de Destinos de Cheques','A',NULL,18,NULL, 2);
	INSERT INTO Permisos VALUES(126,125, 'AltaDestinoCheque', 'Dar de alta destino de cheque', 'A', NULL, '1', 'xsp_alta_destino_cheque', 2);
	INSERT INTO Permisos VALUES(127,125, 'ModificarDestinoCheque', 'Modificar destino de cheque', 'A', NULL, '2', 'xsp_modifica_destino_cheque', 2);
	INSERT INTO Permisos VALUES(128,125, 'BorrarDestinoCheque', 'Borrar destino de cheques', 'A', NULL, '3', 'xsp_borra_destino_cheque', 2);
	INSERT INTO Permisos VALUES(129,125, 'BuscarDestinosCheque', 'Buscar destinos de cheque', 'A', NULL, '4', 'xsp_buscar_destinos_cheques', 2);
	INSERT INTO Permisos VALUES(130,125, 'ActivarDestinoCheque', 'Activar destino de cheque', 'A', NULL, '5', 'xsp_activar_destino_cheque', 2);
	INSERT INTO Permisos VALUES(131,125, 'DarBajaDestinoCheque', 'Dar de baja destino de cheque', 'A', NULL, '6', 'xsp_darbaja_destino_cheque', 2);	

INSERT INTO Permisos VALUES(138,1,'GestionCanales', 'Gestión de Canales','A',NULL,19,NULL, 2);
	INSERT INTO Permisos VALUES(139,138, 'AltaCanal', 'Dar de alta canales', 'A', NULL, '1', 'xsp_alta_canal', 2);
	INSERT INTO Permisos VALUES(140,138, 'ModificarCanal', 'Modificar canales', 'A', NULL, '2', 'xsp_modifica_canal', 2);
	INSERT INTO Permisos VALUES(141,138, 'BuscarCanales', 'Buscar canales', 'A', NULL, '3', 'xsp_buscar_canales', 2);
	INSERT INTO Permisos VALUES(142,138, 'ActivarCanal', 'Activar canales', 'A', NULL, '4', 'xsp_activar_canal', 2);
	INSERT INTO Permisos VALUES(143,138, 'DarBajaCanal', 'Dar de baja canales', 'A', NULL, '5', 'xsp_darbaja_canal', 2);
	INSERT INTO Permisos VALUES(144,138, 'BorrarCanal', 'Borrar canales', 'A', NULL, '6', 'xsp_borra_canal', 2);

INSERT INTO Permisos VALUES(146,1,'GestionSuscripciones', 'Gestión de Suscripciones','A',NULL,20,NULL, 1);
	INSERT INTO Permisos VALUES(147,146, 'AltaSuscripcion', 'Dar de alta una suscripción', 'A', NULL, '1', 'xsp_inicio_alta_suscripcion', 1);
	INSERT INTO Permisos VALUES(148,146, 'DarBajaSuscripcion', 'Dar de baja una suscripción', 'A', NULL, '2', 'xsp_inicio_darbaja_suscripcion', 1);
	INSERT INTO Permisos VALUES(149,146, 'DarBajaPlan', 'Dar de baja un plan', 'A', NULL, '3', 'xsp_baja_plan', 0);

	-- Ú 175
		
-- RolesGenericos
INSERT INTO RolesGenericos VALUES
(1, 'Administrador', 'A', 'Administrador del sistema.');
INSERT INTO RolesGenericos VALUES
(2, 'Vendedor', 'A', 'Vendedor en un Punto de Venta.');

-- Permisos de administrador
INSERT INTO PermisosRolGenerico VALUES(1, 1);
INSERT INTO PermisosRolGenerico VALUES(2, 1);
INSERT INTO PermisosRolGenerico VALUES(3, 1);
INSERT INTO PermisosRolGenerico VALUES(4, 1);
INSERT INTO PermisosRolGenerico VALUES(6, 1);
INSERT INTO PermisosRolGenerico VALUES(7, 1);
INSERT INTO PermisosRolGenerico VALUES(8, 1);
INSERT INTO PermisosRolGenerico VALUES(9, 1);
INSERT INTO PermisosRolGenerico VALUES(10, 1);
INSERT INTO PermisosRolGenerico VALUES(11, 1);
INSERT INTO PermisosRolGenerico VALUES(12, 1);
INSERT INTO PermisosRolGenerico VALUES(13, 1);
INSERT INTO PermisosRolGenerico VALUES(14, 1);
INSERT INTO PermisosRolGenerico VALUES(15, 1);
INSERT INTO PermisosRolGenerico VALUES(16, 1);
INSERT INTO PermisosRolGenerico VALUES(17, 1);
INSERT INTO PermisosRolGenerico VALUES(18, 1);
INSERT INTO PermisosRolGenerico VALUES(19, 1);
INSERT INTO PermisosRolGenerico VALUES(20, 1);
INSERT INTO PermisosRolGenerico VALUES(21, 1);
INSERT INTO PermisosRolGenerico VALUES(22, 1);
INSERT INTO PermisosRolGenerico VALUES(23, 1);
INSERT INTO PermisosRolGenerico VALUES(24, 1);
INSERT INTO PermisosRolGenerico VALUES(25, 1);
INSERT INTO PermisosRolGenerico VALUES(26, 1);
INSERT INTO PermisosRolGenerico VALUES(27, 1);
INSERT INTO PermisosRolGenerico VALUES(28, 1);
INSERT INTO PermisosRolGenerico VALUES(29, 1);
INSERT INTO PermisosRolGenerico VALUES(30, 1);
INSERT INTO PermisosRolGenerico VALUES(31, 1);
INSERT INTO PermisosRolGenerico VALUES(32, 1);
INSERT INTO PermisosRolGenerico VALUES(33, 1);
INSERT INTO PermisosRolGenerico VALUES(34, 1);
INSERT INTO PermisosRolGenerico VALUES(35, 1);
INSERT INTO PermisosRolGenerico VALUES(36, 1);
INSERT INTO PermisosRolGenerico VALUES(37, 1);
INSERT INTO PermisosRolGenerico VALUES(38, 1);
INSERT INTO PermisosRolGenerico VALUES(39, 1);
INSERT INTO PermisosRolGenerico VALUES(40, 1);
INSERT INTO PermisosRolGenerico VALUES(41, 1);
INSERT INTO PermisosRolGenerico VALUES(42, 1);
INSERT INTO PermisosRolGenerico VALUES(43, 1);
INSERT INTO PermisosRolGenerico VALUES(44, 1);
INSERT INTO PermisosRolGenerico VALUES(45, 1);
INSERT INTO PermisosRolGenerico VALUES(46, 1);
INSERT INTO PermisosRolGenerico VALUES(47, 1);
INSERT INTO PermisosRolGenerico VALUES(48, 1);
INSERT INTO PermisosRolGenerico VALUES(49, 1);
INSERT INTO PermisosRolGenerico VALUES(50, 1);
INSERT INTO PermisosRolGenerico VALUES(51, 1);
INSERT INTO PermisosRolGenerico VALUES(52, 1);
INSERT INTO PermisosRolGenerico VALUES(53, 1);
INSERT INTO PermisosRolGenerico VALUES(54, 1);
INSERT INTO PermisosRolGenerico VALUES(55, 1);
INSERT INTO PermisosRolGenerico VALUES(56, 1);
INSERT INTO PermisosRolGenerico VALUES(57, 1);
INSERT INTO PermisosRolGenerico VALUES(58, 1);
INSERT INTO PermisosRolGenerico VALUES(59, 1);
INSERT INTO PermisosRolGenerico VALUES(60, 1);
INSERT INTO PermisosRolGenerico VALUES(61, 1);
INSERT INTO PermisosRolGenerico VALUES(62, 1);
INSERT INTO PermisosRolGenerico VALUES(63, 1);
INSERT INTO PermisosRolGenerico VALUES(64, 1);
INSERT INTO PermisosRolGenerico VALUES(65, 1);
INSERT INTO PermisosRolGenerico VALUES(66, 1);
INSERT INTO PermisosRolGenerico VALUES(67, 1);
INSERT INTO PermisosRolGenerico VALUES(68, 1);
INSERT INTO PermisosRolGenerico VALUES(69, 1);
INSERT INTO PermisosRolGenerico VALUES(70, 1);
INSERT INTO PermisosRolGenerico VALUES(71, 1);
INSERT INTO PermisosRolGenerico VALUES(72, 1);
INSERT INTO PermisosRolGenerico VALUES(73, 1);
INSERT INTO PermisosRolGenerico VALUES(74, 1);
INSERT INTO PermisosRolGenerico VALUES(75, 1);
INSERT INTO PermisosRolGenerico VALUES(76, 1);
INSERT INTO PermisosRolGenerico VALUES(77, 1);
INSERT INTO PermisosRolGenerico VALUES(78, 1);
INSERT INTO PermisosRolGenerico VALUES(79, 1);
INSERT INTO PermisosRolGenerico VALUES(80, 1);
INSERT INTO PermisosRolGenerico VALUES(81, 1);
INSERT INTO PermisosRolGenerico VALUES(82, 1);
INSERT INTO PermisosRolGenerico VALUES(83, 1);
INSERT INTO PermisosRolGenerico VALUES(84, 1);
INSERT INTO PermisosRolGenerico VALUES(85, 1);
INSERT INTO PermisosRolGenerico VALUES(86, 1);
INSERT INTO PermisosRolGenerico VALUES(87, 1);
INSERT INTO PermisosRolGenerico VALUES(88, 1);
INSERT INTO PermisosRolGenerico VALUES(89, 1);
INSERT INTO PermisosRolGenerico VALUES(90, 1);
INSERT INTO PermisosRolGenerico VALUES(91, 1);
INSERT INTO PermisosRolGenerico VALUES(92, 1);
INSERT INTO PermisosRolGenerico VALUES(93, 1);
INSERT INTO PermisosRolGenerico VALUES(94, 1);
INSERT INTO PermisosRolGenerico VALUES(95, 1);
INSERT INTO PermisosRolGenerico VALUES(96, 1);
INSERT INTO PermisosRolGenerico VALUES(97, 1);
INSERT INTO PermisosRolGenerico VALUES(98, 1);
INSERT INTO PermisosRolGenerico VALUES(99, 1);
INSERT INTO PermisosRolGenerico VALUES(100, 1);
INSERT INTO PermisosRolGenerico VALUES(101, 1);
INSERT INTO PermisosRolGenerico VALUES(102, 1);
INSERT INTO PermisosRolGenerico VALUES(103, 1);
INSERT INTO PermisosRolGenerico VALUES(104, 1);
INSERT INTO PermisosRolGenerico VALUES(105, 1);
INSERT INTO PermisosRolGenerico VALUES(106, 1);
INSERT INTO PermisosRolGenerico VALUES(107, 1);
INSERT INTO PermisosRolGenerico VALUES(108, 1);
INSERT INTO PermisosRolGenerico VALUES(109, 1);
INSERT INTO PermisosRolGenerico VALUES(110, 1);
INSERT INTO PermisosRolGenerico VALUES(111, 1);
INSERT INTO PermisosRolGenerico VALUES(112, 1);
INSERT INTO PermisosRolGenerico VALUES(113, 1);
INSERT INTO PermisosRolGenerico VALUES(114, 1);
INSERT INTO PermisosRolGenerico VALUES(115, 1);
INSERT INTO PermisosRolGenerico VALUES(116, 1);
INSERT INTO PermisosRolGenerico VALUES(117, 1);
INSERT INTO PermisosRolGenerico VALUES(118, 1);
INSERT INTO PermisosRolGenerico VALUES(119, 1);
INSERT INTO PermisosRolGenerico VALUES(120, 1);
INSERT INTO PermisosRolGenerico VALUES(121, 1);
INSERT INTO PermisosRolGenerico VALUES(122, 1);
INSERT INTO PermisosRolGenerico VALUES(123, 1);
INSERT INTO PermisosRolGenerico VALUES(124, 1);
INSERT INTO PermisosRolGenerico VALUES(125, 1);
INSERT INTO PermisosRolGenerico VALUES(126, 1);
INSERT INTO PermisosRolGenerico VALUES(127, 1);
INSERT INTO PermisosRolGenerico VALUES(128, 1);
INSERT INTO PermisosRolGenerico VALUES(129, 1);
INSERT INTO PermisosRolGenerico VALUES(130, 1);
INSERT INTO PermisosRolGenerico VALUES(131, 1);
INSERT INTO PermisosRolGenerico VALUES(132, 1);
INSERT INTO PermisosRolGenerico VALUES(133, 1);
INSERT INTO PermisosRolGenerico VALUES(134, 1);
INSERT INTO PermisosRolGenerico VALUES(135, 1);
INSERT INTO PermisosRolGenerico VALUES(136, 1);
INSERT INTO PermisosRolGenerico VALUES(137, 1);
INSERT INTO PermisosRolGenerico VALUES(138, 1);
INSERT INTO PermisosRolGenerico VALUES(139, 1);
INSERT INTO PermisosRolGenerico VALUES(140, 1);
INSERT INTO PermisosRolGenerico VALUES(141, 1);
INSERT INTO PermisosRolGenerico VALUES(142, 1);
INSERT INTO PermisosRolGenerico VALUES(143, 1);
INSERT INTO PermisosRolGenerico VALUES(144, 1);
INSERT INTO PermisosRolGenerico VALUES(145, 1);
INSERT INTO PermisosRolGenerico VALUES(150, 1);
INSERT INTO PermisosRolGenerico VALUES(151, 1);
INSERT INTO PermisosRolGenerico VALUES(152, 1);
INSERT INTO PermisosRolGenerico VALUES(153, 1);
INSERT INTO PermisosRolGenerico VALUES(154, 1);
INSERT INTO PermisosRolGenerico VALUES(155, 1);
INSERT INTO PermisosRolGenerico VALUES(156, 1);
INSERT INTO PermisosRolGenerico VALUES(157, 1);
INSERT INTO PermisosRolGenerico VALUES(158, 1);
INSERT INTO PermisosRolGenerico VALUES(159, 1);
INSERT INTO PermisosRolGenerico VALUES(160, 1);
INSERT INTO PermisosRolGenerico VALUES(161, 1);
INSERT INTO PermisosRolGenerico VALUES(162, 1);
INSERT INTO PermisosRolGenerico VALUES(163, 1);
INSERT INTO PermisosRolGenerico VALUES(164, 1);
INSERT INTO PermisosRolGenerico VALUES(165, 1);
INSERT INTO PermisosRolGenerico VALUES(166, 1);
INSERT INTO PermisosRolGenerico VALUES(167, 1);
INSERT INTO PermisosRolGenerico VALUES(168, 1);
INSERT INTO PermisosRolGenerico VALUES(169, 1);
INSERT INTO PermisosRolGenerico VALUES(170, 1);
INSERT INTO PermisosRolGenerico VALUES(171, 1);
INSERT INTO PermisosRolGenerico VALUES(172, 1);
INSERT INTO PermisosRolGenerico VALUES(173, 1);
INSERT INTO PermisosRolGenerico VALUES(174, 1);
INSERT INTO PermisosRolGenerico VALUES(175, 1);
-- Permisos de Vendedor
INSERT INTO PermisosRolGenerico VALUES(46, 2);
INSERT INTO PermisosRolGenerico VALUES(47, 2);
INSERT INTO PermisosRolGenerico VALUES(48, 2);
INSERT INTO PermisosRolGenerico VALUES(49, 2);
INSERT INTO PermisosRolGenerico VALUES(50, 2);
INSERT INTO PermisosRolGenerico VALUES(51, 2);
INSERT INTO PermisosRolGenerico VALUES(52, 2);
INSERT INTO PermisosRolGenerico VALUES(53, 2);
INSERT INTO PermisosRolGenerico VALUES(54, 2);
INSERT INTO PermisosRolGenerico VALUES(65, 2);
INSERT INTO PermisosRolGenerico VALUES(66, 2);
INSERT INTO PermisosRolGenerico VALUES(67, 2);
INSERT INTO PermisosRolGenerico VALUES(68, 2);
INSERT INTO PermisosRolGenerico VALUES(69, 2);
INSERT INTO PermisosRolGenerico VALUES(70, 2);
INSERT INTO PermisosRolGenerico VALUES(71, 2);
INSERT INTO PermisosRolGenerico VALUES(72, 2);
INSERT INTO PermisosRolGenerico VALUES(73, 2);
INSERT INTO PermisosRolGenerico VALUES(74, 2);
INSERT INTO PermisosRolGenerico VALUES(75, 2);
INSERT INTO PermisosRolGenerico VALUES(76, 2);
INSERT INTO PermisosRolGenerico VALUES(77, 2);
INSERT INTO PermisosRolGenerico VALUES(78, 2);
INSERT INTO PermisosRolGenerico VALUES(79, 2);
INSERT INTO PermisosRolGenerico VALUES(80, 2);
INSERT INTO PermisosRolGenerico VALUES(81, 2);
INSERT INTO PermisosRolGenerico VALUES(82, 2);
INSERT INTO PermisosRolGenerico VALUES(83, 2);
INSERT INTO PermisosRolGenerico VALUES(85, 2);
INSERT INTO PermisosRolGenerico VALUES(86, 2);
INSERT INTO PermisosRolGenerico VALUES(87, 2);
INSERT INTO PermisosRolGenerico VALUES(88, 2);
INSERT INTO PermisosRolGenerico VALUES(89, 2);
INSERT INTO PermisosRolGenerico VALUES(90, 2);
INSERT INTO PermisosRolGenerico VALUES(91, 2);
INSERT INTO PermisosRolGenerico VALUES(92, 2);
INSERT INTO PermisosRolGenerico VALUES(93, 2);
INSERT INTO PermisosRolGenerico VALUES(94, 2);
INSERT INTO PermisosRolGenerico VALUES(95, 2);
INSERT INTO PermisosRolGenerico VALUES(96, 2);
INSERT INTO PermisosRolGenerico VALUES(97, 2);
INSERT INTO PermisosRolGenerico VALUES(98, 2);
INSERT INTO PermisosRolGenerico VALUES(99, 2);
INSERT INTO PermisosRolGenerico VALUES(100, 2);
INSERT INTO PermisosRolGenerico VALUES(101, 2);
INSERT INTO PermisosRolGenerico VALUES(102, 2);
INSERT INTO PermisosRolGenerico VALUES(103, 2);
INSERT INTO PermisosRolGenerico VALUES(104, 2);
INSERT INTO PermisosRolGenerico VALUES(105, 2);
INSERT INTO PermisosRolGenerico VALUES(106, 2);
INSERT INTO PermisosRolGenerico VALUES(107, 2);
INSERT INTO PermisosRolGenerico VALUES(108, 2);
INSERT INTO PermisosRolGenerico VALUES(109, 2);
INSERT INTO PermisosRolGenerico VALUES(116, 2);
INSERT INTO PermisosRolGenerico VALUES(117, 2);
INSERT INTO PermisosRolGenerico VALUES(118, 2);
INSERT INTO PermisosRolGenerico VALUES(119, 2);
INSERT INTO PermisosRolGenerico VALUES(120, 2);
INSERT INTO PermisosRolGenerico VALUES(121, 2);
INSERT INTO PermisosRolGenerico VALUES(132, 2);
INSERT INTO PermisosRolGenerico VALUES(133, 2);
INSERT INTO PermisosRolGenerico VALUES(134, 2);
INSERT INTO PermisosRolGenerico VALUES(135, 2);
INSERT INTO PermisosRolGenerico VALUES(136, 2);
INSERT INTO PermisosRolGenerico VALUES(145, 2);
INSERT INTO PermisosRolGenerico VALUES(150, 2);
INSERT INTO PermisosRolGenerico VALUES(151, 2);
INSERT INTO PermisosRolGenerico VALUES(174, 2);
INSERT INTO PermisosRolGenerico VALUES(175, 2);

-- Genero datos de empresa inicial
call xsp_generar_datos_empresa(1, @mensaje);
SELECT @mensaje AltaEmpresa;

INSERT INTO Usuarios VALUES (1, 1, 'Miguel', 'Liezun', 'mliezun', md5('mliezun'), '', 'liezun.js@gmail.com', '0', NOW(), NOW(), 'N', 'A', NULL, 1);
INSERT INTO Usuarios VALUES (2, 1, 'Mauricio', 'Sanchez Lopez', 'fox', md5('fox'), '', 'mau.slgym@gmail.com', '0', NOW(), NOW(), 'N', 'A', NULL, 1);

-- Tipos de Gravamenes
-- INSERT INTO TiposGravamenes VALUES(1,'IVA21',1.21,NULL);
-- INSERT INTO TiposGravamenes VALUES(2,'IVA11',1.21,NULL);

-- Medios de Pago
INSERT INTO MediosPago VALUES(1,'Efectivo','A');
INSERT INTO MediosPago VALUES(2,'Mercaderia','A');
INSERT INTO MediosPago VALUES(3,'Tarjeta','A');
INSERT INTO MediosPago VALUES(4,'Otro','B');
INSERT INTO MediosPago VALUES(5,'Cheque','A');
INSERT INTO MediosPago VALUES(6,'Deposito','A');
INSERT INTO MediosPago VALUES(7,'Retencion','A');
INSERT INTO MediosPago VALUES(8,'Descuento','A');
INSERT INTO MediosPago VALUES(9,'Nota de credito','B');
INSERT INTO MediosPago VALUES(10,'Nota de debito','B');
INSERT INTO MediosPago VALUES(11,'Debito de Cuenta Corriente','B');

INSERT INTO TiposComprobante VALUES(1,'Factura A','A');
INSERT INTO TiposComprobante VALUES(6,'Factura B','A');
INSERT INTO TiposComprobante VALUES(11,'Factura C','A');
INSERT INTO TiposComprobante VALUES(995,'REMITO ELECTRÓNICO CÁRNICO ','A');
