# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.

import values
from fpdf import Template
from decimal import Decimal
from aiofile import AIOFile, LineReader
from hashlib import md5
import traceback
import tempfile
import sys
import os
import decimal
import datetime

__author__ = "Miguel Liezun <liezun.js@gmail.com>"
__copyright__ = "Copyright (C) 2011-2018 Mariano Reingart | 2019 Miguel Liezun"
__license__ = "GPL 3.0"
__version__ = "0.0.1"

DEBUG = False
HOMO = True if DEBUG else False
CONFIG_FILE = "config.ini"
INSTALL_DIR = os.path.dirname(os.path.abspath(__file__))


class FEPDF:
    tipos_doc = values.document_types

    umeds_ds = values.measure_units

    ivas_ds = values.vat_types

    paises = values.countries

    monedas_ds = values.currencies

    tributos_ds = values.tax_types

    tipos_fact = values.invoice_types

    letras_fact = values.letter_invoices

    def __init__(self, presupuesto=False):
        self.Version = __version__
        self.factura = None
        self.Exception = self.Traceback = ""
        self.InstallDir = INSTALL_DIR
        self.Locale = "es_AR.utf8"
        self.FmtCantidad = self.FmtPrecio = "0.2"
        self.CUIT = ''
        self.factura = {}
        self.datos = []
        self.elements = []
        self.pdf = {}
        self.title = 'Presupuesto' if presupuesto else 'Factura'
        self.presupuesto = presupuesto

    def inicializar(self):
        self.Excepcion = self.Traceback = ""

    def CrearFactura(self, concepto=1, tipo_doc=80, nro_doc="", tipo_cbte=1, punto_vta=0,
                     cbte_nro=0, imp_total=0.00, imp_tot_conc=0.00, imp_neto=0.00,
                     imp_iva=0.00, imp_trib=0.00, imp_op_ex=0.00, fecha_cbte="", fecha_venc_pago="",
                     fecha_serv_desde=None, fecha_serv_hasta=None,
                     moneda_id="PES", moneda_ctz="1.0000", cae="", fch_venc_cae="", id_impositivo='',
                     nombre_cliente="", domicilio_cliente="", pais_dst_cmp=None,
                     obs_comerciales="", obs_generales="", forma_pago="", incoterms="",
                     idioma_cbte=7, motivos_obs="", descuento=0.0,
                     **kwargs
                     ):
        "Creo un objeto factura (internamente)"
        fact = {'tipo_doc': tipo_doc, 'nro_doc':  nro_doc,
                'tipo_cbte': tipo_cbte, 'punto_vta': punto_vta,
                'cbte_nro': cbte_nro,
                'imp_total': imp_total, 'imp_tot_conc': imp_tot_conc,
                'imp_neto': imp_neto, 'imp_iva': imp_iva,
                'imp_trib': imp_trib, 'imp_op_ex': imp_op_ex,
                'fecha_cbte': fecha_cbte,
                'fecha_venc_pago': fecha_venc_pago,
                'moneda_id': moneda_id, 'moneda_ctz': moneda_ctz,
                'concepto': concepto,
                'nombre_cliente': nombre_cliente,
                'domicilio_cliente': domicilio_cliente,
                'pais_dst_cmp': pais_dst_cmp,
                'obs_comerciales': obs_comerciales,
                'obs_generales': obs_generales,
                'id_impositivo': id_impositivo,
                'forma_pago': forma_pago, 'incoterms': incoterms,
                'cae': cae, 'fecha_vto': fch_venc_cae,
                'motivos_obs': motivos_obs,
                'descuento': descuento,
                'cbtes_asoc': [],
                'tributos': [],
                'ivas': [],
                'permisos': [],
                'detalles': [],
                }
        if fecha_serv_desde:
            fact['fecha_serv_desde'] = fecha_serv_desde
        if fecha_serv_hasta:
            fact['fecha_serv_hasta'] = fecha_serv_hasta

        if self.presupuesto:
            fact['descuento'] = None
            fact['imp_op_ex'] = None
            fact['imp_tot_conc'] = None

        self.factura = fact
        return True

    def EstablecerParametro(self, parametro, valor):
        "Modifico un parametro general a la factura (internamente)"
        self.factura[parametro] = valor
        return True

    def AgregarDato(self, campo, valor, pagina='T'):
        "Agrego un dato a la factura (internamente)"
        self.datos.append({'campo': campo, 'valor': valor, 'pagina': pagina})
        return True

    def AgregarDetalleItem(self, u_mtx='', cod_mtx='', codigo='', ds='', qty=0.0, umed=7, precio=0.0,
                           bonif=0.0, iva_id=0, imp_iva=0, importe=0.0, despacho='',
                           dato_a=None, dato_b=None, dato_c=None, dato_d=None, dato_e=None):
        "Agrego un item a una factura (internamente)"
        # ds = unicode(ds, "utf-8") # convierto a utf-8
        # Nota: no se calcula neto, iva, etc (deben venir calculados!)
        item = {
            'u_mtx': u_mtx,
            'cod_mtx': cod_mtx,
            'codigo': codigo,
            'ds': ds,
            'qty': qty,
            'umed': umed,
            'precio': precio,
            'bonif': bonif,
            'iva_id': iva_id,
            'imp_iva': imp_iva,
            'importe': importe,
            'despacho': despacho,
            'dato_a': dato_a,
            'dato_b': dato_b,
            'dato_c': dato_c,
            'dato_d': dato_d,
            'dato_e': dato_e,
        }
        self.factura['detalles'].append(item)
        return True

    def AgregarCmpAsoc(self, tipo=1, pto_vta=0, nro=0, **kwarg):
        "Agrego un comprobante asociado a una factura (interna)"
        cmp_asoc = {'cbte_tipo': tipo,
                    'cbte_punto_vta': pto_vta, 'cbte_nro': nro}
        self.factura['cbtes_asoc'].append(cmp_asoc)
        return True

    def AgregarTributo(self, tributo_id=0, desc="", base_imp=0.00, alic=0, importe=0.00, **kwarg):
        "Agrego un tributo a una factura (interna)"
        tributo = {'tributo_id': tributo_id, 'desc': desc, 'base_imp': base_imp,
                   'alic': alic, 'importe': importe}
        self.factura['tributos'].append(tributo)
        return True

    def AgregarIva(self, iva_id=0, base_imp=0.0, importe=0.0, **kwarg):
        "Agrego un tributo a una factura (interna)"
        iva = {'iva_id': iva_id, 'base_imp': base_imp, 'importe': importe}
        self.factura['ivas'].append(iva)
        return True

    def AgregarPermiso(self, id_permiso, dst_merc, **kwargs):
        "Agrego un permiso a una factura (interna)"
        self.factura['permisos'].append({
            'id_permiso': id_permiso,
            'dst_merc': dst_merc,
        })
        return True

    # funciones de formateo de strings:

    def fmt_date(self, d):
        "Formatear una fecha"
        if not d or len(d) != 8:
            return d or ''
        else:
            return "%s/%s/%s" % (d[6:8], d[4:6], d[0:4])

    def fmt_num(self, i, fmt="%0.2f", monetary=True):
        "Formatear un número"
        if i is not None and str(i) and not isinstance(i, bool):
            loc = self.Locale
            if loc:
                import locale
                locale.setlocale(locale.LC_ALL, loc)
                return locale.format_string(fmt, Decimal(str(i).replace(",", ".")), grouping=True, monetary=monetary)
            else:
                return (fmt % Decimal(str(i).replace(",", "."))).replace(".", ",")
        else:
            return ''

    def fmt_imp(self, i): return self.fmt_num(i, "%0.2f")
    def fmt_qty(self, i): return self.fmt_num(
        i, "%" + self.FmtCantidad + "f", False)

    def fmt_pre(self, i): return self.fmt_num(i, "%" + self.FmtPrecio + "f")

    def fmt_iva(self, i):
        if int(i) in self.ivas_ds:
            p = self.ivas_ds[int(i)]
            if p == int(p):
                return self.fmt_num(p, "%d") + "%"
            else:
                return self.fmt_num(p, "%.1f") + "%"
        else:
            return ""

    def fmt_cuit(self, c):
        if c is not None and str(c):
            c = str(c)
            return len(c) == 11 and "%s-%s-%s" % (c[0:2], c[2:10], c[10:]) or c
        return ''

    def fmt_fact(self, tipo_cbte, punto_vta, cbte_nro):
        "Formatear tipo, letra y punto de venta y número de factura"
        n = "%05d-%08d" % (int(punto_vta), int(cbte_nro))
        t, l = tipo_cbte, ''
        if self.presupuesto:
            t = 'Presupuesto'
        else:
            for k, v in list(self.tipos_fact.items()):
                if int(tipo_cbte) in k:
                    t = v
        for k, v in list(self.letras_fact.items()):
            if int(int(tipo_cbte)) in k:
                l = v
        return t, l, n

    def digito_verificador_modulo10(self, codigo):
        "Rutina para el cálculo del dígito verificador 'módulo 10'"
        # http://www.consejo.org.ar/Bib_elect/diciembre04_CT/documentos/rafip1702.htm
        # Etapa 1: comenzar desde la izquierda, sumar todos los caracteres ubicados en las posiciones impares.
        codigo = codigo.strip()
        if not codigo or not codigo.isdigit():
            return ''
        etapa1 = sum([int(c) for i, c in enumerate(codigo) if not i % 2])
        # Etapa 2: multiplicar la suma obtenida en la etapa 1 por el número 3
        etapa2 = etapa1 * 3
        # Etapa 3: comenzar desde la izquierda, sumar todos los caracteres que están ubicados en las posiciones pares.
        etapa3 = sum([int(c) for i, c in enumerate(codigo) if i % 2])
        # Etapa 4: sumar los resultados obtenidos en las etapas 2 y 3.
        etapa4 = etapa2 + etapa3
        # Etapa 5: buscar el menor número que sumado al resultado obtenido en la etapa 4 de un número múltiplo de 10. Este será el valor del dígito verificador del módulo 10.
        digito = 10 - (etapa4 - (int(etapa4 / 10) * 10))
        if digito == 10:
            digito = 0
        return str(digito)

    # Funciones públicas:

    async def CargarFormato(self, archivo):
        "Cargo el formato de campos a generar desde una planilla CSV"

        # si no encuentro archivo, lo busco en el directorio predeterminado:
        if not os.path.exists(archivo):
            archivo = os.path.join(
                self.InstallDir, "plantillas", os.path.basename(archivo))

        if DEBUG:
            print("abriendo archivo ", archivo)

        lineas = []
        async with AIOFile(archivo, 'rb') as plantilla:
            async for s in LineReader(plantilla):
                lineas.append(s.decode('unicode_escape'))

        for lno, linea in enumerate(lineas):
            if DEBUG:
                print("procesando linea ", lno, linea)
            args = []
            for i, v in enumerate(linea.split(";")):
                if not v.startswith("'"):
                    v = v.replace(",", ".")
                else:
                    v = v  # .decode('utf-8')
                if v.strip() == '':
                    v = None
                else:
                    v = eval(v.strip())
                args.append(v)
            self.AgregarCampo(*args)
        return True

    def AgregarCampo(self, nombre, tipo, x1, y1, x2, y2,
                     font="Arial", size=12,
                     bold=False, italic=False, underline=False,
                     foreground=0x000000, background=0xFFFFFF,
                     align="L", text="", priority=0, **kwargs):
        "Agrego un campo a la plantilla"
        # convierto colores de string (en hexadecimal)
        if isinstance(foreground, str):
            foreground = int(foreground, 16)
        if isinstance(background, str):
            background = int(background, 16)
        # if isinstance(text, str):
        #    text = text.encode("utf-8")
        field = {
            'name': nombre,
            'type': tipo,
            'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2,
            'font': font, 'size': size,
            'bold': bold, 'italic': italic, 'underline': underline,
            'foreground': foreground, 'background': background,
            'align': align, 'text': text, 'priority': priority}
        field.update(kwargs)
        self.elements.append(field)
        return True

    def CrearPlantilla(self, papel="A4", orientacion="portrait"):
        "Iniciar la creación del archivo PDF"

        fact = self.factura
        tipo, letra, nro = self.fmt_fact(
            fact['tipo_cbte'], fact['punto_vta'], fact['cbte_nro'])

        if HOMO:
            self.AgregarCampo("homo", 'T', 100, 250, 0, 0,
                              size=70, rotate=45, foreground=0x808080, priority=-1)

        # sanity check:
        for field in self.elements:
            # si la imagen no existe, eliminar nombre para que no falle fpdf
            if field['type'] == 'I' and not os.path.exists(field["text"]):
                # ajustar rutas relativas a las imágenes predeterminadas:
                if os.path.exists(os.path.join(self.InstallDir, field["text"])):
                    field['text'] = os.path.join(
                        self.InstallDir, field["text"])
                else:
                    field['text'] = ""

        if self.presupuesto:
            self.title = f'Presupuesto {fact["cae"]}'
        else:
            self.title = f'{tipo} {letra} {nro}'

        # genero el renderizador con propiedades del PDF
        t = Template(elements=self.elements,
                     format=papel, orientation=orientacion,
                     title=self.title,
                     author=f'CUIT {self.CUIT}',
                     subject=f'CAE {fact["cae"]}',
                     keywords='AFIP Factura Electrónica',
                     creator='GestionX',)
        self.template = t
        return True

    def ProcesarPlantilla(self, num_copias=3, lineas_max=36, qty_pos='izq'):
        "Generar el PDF según la factura creada y plantilla cargada"

        ret = False
        try:
            if isinstance(num_copias, str):
                num_copias = int(num_copias)
            if isinstance(lineas_max, str):
                lineas_max = int(lineas_max)

            f = self.template
            fact = self.factura

            tipo_fact, letra_fact, numero_fact = self.fmt_fact(
                fact['tipo_cbte'], fact['punto_vta'], fact['cbte_nro'])
            fact['_fmt_fact'] = tipo_fact, letra_fact, numero_fact
            if fact['tipo_cbte'] in (19, 20, 21):
                tipo_fact_ex = tipo_fact + " de Exportación"
            else:
                tipo_fact_ex = tipo_fact

            # dividir y contar líneas:
            lineas = 0
            li_items = []
            for it in fact['detalles']:
                qty = qty_pos == 'izq' and it['qty'] or None
                codigo = it['codigo']
                umed = it['umed']
                # si umed es 0 (desc.), no imprimir cant/importes en 0
                if umed is not None and umed != "":
                    umed = int(umed)
                ds = it['ds'] or ""
                if '\x00' in ds:
                    # limpiar descripción (campos dbf):
                    ds = ds.replace('\x00', '')
                if '<br/>' in ds:
                    # reemplazar saltos de linea:
                    ds = ds.replace('<br/>', '\n')
                if DEBUG:
                    print("dividiendo", ds)
                # divido la descripción (simil celda múltiple de PDF)
                n_li = 0
                for ds in f.split_multicell(ds, 'Item.Descripcion01'):
                    if DEBUG:
                        print("multicell", ds)
                    # agrego un item por linea (sin precio ni importe):
                    li_items.append(dict(codigo=codigo, ds=ds, qty=qty,
                                         umed=umed if not n_li else None,
                                         precio=None, importe=None))
                    # limpio cantidad y código (solo en el primero)
                    qty = codigo = None
                    n_li += 1
                # asigno el precio a la última línea del item
                li_items[-1].update(importe=it['importe'] if float(it['importe'] or 0) or umed else None,
                                    despacho=it.get('despacho'),
                                    precio=it['precio'] if float(
                                        it['precio'] or 0) or umed else None,
                                    qty=(n_li == 1 or qty_pos ==
                                         'der') and it['qty'] or None,
                                    bonif=it.get('bonif') if float(
                                        it['bonif'] or 0) or umed else None,
                                    iva_id=it.get('iva_id'),
                                    imp_iva=it.get('imp_iva'),
                                    dato_a=it.get('dato_a'),
                                    dato_b=it.get('dato_b'),
                                    dato_c=it.get('dato_c'),
                                    dato_d=it.get('dato_d'),
                                    dato_e=it.get('dato_e'),
                                    u_mtx=it.get('u_mtx'),
                                    cod_mtx=it.get('cod_mtx'),
                                    )

            # reemplazar saltos de linea en observaciones:
            for k in ('obs_generales', 'obs_comerciales'):
                ds = fact.get(k, '')
                if isinstance(ds, str) and '<br/>' in ds:
                    fact[k] = ds.replace('<br/>', '\n')

            # divido las observaciones por linea:
            if fact.get('obs_generales') and not f.has_key('obs') and not f.has_key('ObservacionesGenerales1'):
                obs = "\n<U>Observaciones:</U>\n\n" + fact['obs_generales']
                # limpiar texto (campos dbf) y reemplazar saltos de linea:
                obs = obs.replace('\x00', '').replace('<br/>', '\n')
                for ds in f.split_multicell(obs, 'Item.Descripcion01'):
                    li_items.append(
                        dict(codigo=None, ds=ds, qty=None, umed=None, precio=None, importe=None))

            if fact.get('obs_comerciales') and not f.has_key('obs_comerciales') and not f.has_key('ObservacionesComerciales1'):
                obs = "\n<U>Observaciones Comerciales:</U>\n\n" + \
                    fact['obs_comerciales']
                # limpiar texto (campos dbf) y reemplazar saltos de linea:
                obs = obs.replace('\x00', '').replace('<br/>', '\n')
                for ds in f.split_multicell(obs, 'Item.Descripcion01'):
                    li_items.append(
                        dict(codigo=None, ds=ds, qty=None, umed=None, precio=None, importe=None))

            # agrego permisos a descripciones (si corresponde)
            permisos = ['Codigo de Despacho %s - Destino de la mercadería: %s' % (
                p['id_permiso'], self.paises.get(p['dst_merc'], p['dst_merc']))
                for p in fact.get('permisos', [])]
            #import dbg; dbg.set_trace()
            if f.has_key('permiso.id1') and f.has_key("permiso.delivery1"):
                for i, p in enumerate(fact.get('permisos', [])):
                    self.AgregarDato("permiso.id%d" % (i+1), p['id_permiso'])
                    pais_dst = self.paises.get(p['dst_merc'], p['dst_merc'])
                    self.AgregarDato("permiso.delivery%d" % (i+1), pais_dst)
            elif not f.has_key('permisos') and permisos:
                obs = "\n<U>Permisos de Embarque:</U>\n\n" + \
                    '\n'.join(permisos)
                for ds in f.split_multicell(obs, 'Item.Descripcion01'):
                    li_items.append(
                        dict(codigo=None, ds=ds, qty=None, umed=None, precio=None, importe=None))
            permisos_ds = ', '.join(permisos)

            # agrego comprobantes asociados
            cmps_asoc = ['%s %s %s' % self.fmt_fact(c['cbte_tipo'], c['cbte_punto_vta'], c['cbte_nro'])
                         for c in fact.get('cbtes_asoc', [])]
            if not f.has_key('cmps_asoc') and cmps_asoc:
                obs = "\n<U>Comprobantes Asociados:</U>\n\n" + \
                    '\n'.join(cmps_asoc)
                for ds in f.split_multicell(obs, 'Item.Descripcion01'):
                    li_items.append(
                        dict(codigo=None, ds=ds, qty=None, umed=None, precio=None, importe=None))
            cmps_asoc_ds = ', '.join(cmps_asoc)

            # calcular cantidad de páginas:
            lineas = len(li_items)
            if lineas_max > 0:
                hojas = lineas // (lineas_max - 1)
                if lineas % (lineas_max - 1):
                    hojas = hojas + 1
                if not hojas:
                    hojas = 1
            else:
                hojas = 1

            if HOMO:
                self.AgregarDato("homo", "HOMOLOGACIÓN")

            # mostrar las validaciones no excluyentes de AFIP (observaciones)

            if fact.get('motivos_obs') and fact['motivos_obs'] != '00':
                if not f.has_key('motivos_ds.L'):
                    motivos_ds = "Irregularidades observadas por AFIP (F136): %s" % fact[
                        'motivos_obs']
                else:
                    motivos_ds = "%s" % fact['motivos_obs']
            elif HOMO:
                motivos_ds = "Ejemplo Sin validez fiscal - Homologación - Testing"
            else:
                motivos_ds = ""

            if letra_fact in ('A', 'M'):
                msg_no_iva = "\nEl IVA discriminado no puede computarse como Crédito Fiscal (RG2485/08 Art. 30 inc. c)."
                if not f.has_key('leyenda_credito_fiscal') and motivos_ds:
                    motivos_ds += msg_no_iva

            copias = {1: 'Original', 2: 'Duplicado', 3: 'Triplicado'}

            for copia in range(1, num_copias+1):

                # completo campos y hojas
                for hoja in range(1, hojas+1):
                    f.add_page()
                    f.set('copia', copias.get(copia, "Adicional %s" % copia))
                    f.set('hoja', str(hoja))
                    f.set('hojas', str(hojas))
                    f.set('pagina', 'Pagina %s de %s' % (hoja, hojas))
                    if hojas > 1 and hoja < hojas:
                        s = 'Continua en hoja %s' % (hoja+1)
                    else:
                        s = ''
                    f.set('continua', s)
                    f.set('Item.Descripcion%02d' % (lineas_max+1), s)

                    if hoja > 1:
                        s = 'Continua de hoja %s' % (hoja-1)
                    else:
                        s = ''
                    f.set('continua_de', s)
                    f.set('Item.Descripcion%02d' % (0), s)

                    if DEBUG:
                        print("generando pagina %s de %s" % (hoja, hojas))

                    # establezco datos según configuración:
                    for d in self.datos:
                        if d['pagina'] == 'P' and hoja != 1:
                            continue
                        if d['pagina'] == 'U' and hojas != hoja:
                            # no es la última hoja
                            continue
                        f.set(d['campo'], d['valor'])

                    # establezco campos según tabla encabezado:
                    for k, v in list(fact.items()):
                        f.set(k, v)

                    f.set('Numero', numero_fact)
                    f.set('Fecha', self.fmt_date(fact['fecha_cbte']))
                    f.set('Vencimiento', self.fmt_date(
                        fact['fecha_venc_pago']))

                    if self.presupuesto:
                        f.set('LETRA', 'X')
                        f.set('TipoCBTE', "")
                    else:
                        f.set('LETRA', letra_fact)
                        f.set('TipoCBTE', "COD.%02d" % int(fact['tipo_cbte']))

                    f.set('Comprobante.L', tipo_fact)
                    f.set('ComprobanteEx.L', tipo_fact_ex)

                    if fact.get('fecha_serv_desde'):
                        f.set('Periodo.Desde', self.fmt_date(
                            fact['fecha_serv_desde']))
                        f.set('Periodo.Hasta', self.fmt_date(
                            fact['fecha_serv_hasta']))
                    else:
                        for k in 'Periodo.Desde', 'Periodo.Hasta', 'PeriodoFacturadoL':
                            f.set(k, '')

                    f.set('Cliente.Nombre', fact.get(
                        'nombre', fact.get('nombre_cliente')))
                    f.set('Cliente.Domicilio', fact.get(
                        'domicilio', fact.get('domicilio_cliente')))
                    f.set('Cliente.Localidad', fact.get(
                        'localidad', fact.get('localidad_cliente')))
                    f.set('Cliente.Provincia', fact.get(
                        'provincia', fact.get('provincia_cliente')))
                    f.set('Cliente.Telefono', fact.get(
                        'telefono', fact.get('telefono_cliente')))
                    f.set('Cliente.IVA', fact.get(
                        'categoria', fact.get('id_impositivo')))
                    f.set('Cliente.CUIT', self.fmt_cuit(str(fact['nro_doc'])))
                    f.set('Cliente.TipoDoc', "%s:" %
                          self.tipos_doc[int(str(fact['tipo_doc']))])
                    f.set('Cliente.Observaciones', fact.get('obs_comerciales'))
                    f.set('Cliente.PaisDestino', self.paises.get(
                        fact.get('pais_dst_cmp'), fact.get('pais_dst_cmp')) or '')

                    if fact['moneda_id']:
                        f.set('moneda_ds', self.monedas_ds.get(
                            fact['moneda_id'], ''))
                    else:
                        for k in 'moneda.L', 'moneda_id', 'moneda_ds', 'moneda_ctz.L', 'moneda_ctz':
                            f.set(k, '')

                    if not fact.get('incoterms'):
                        for k in 'incoterms.L', 'incoterms', 'incoterms_ds':
                            f.set(k, '')

                    li = 0
                    k = 0
                    subtotal = Decimal("0.00")
                    for it in li_items:
                        k = k + 1
                        if k > hoja * (lineas_max - 1):
                            break
                        # acumular subtotal (sin IVA facturas A):
                        if it['importe']:
                            subtotal += Decimal("%.6f" % float(it['importe']))
                            if letra_fact in ('A', 'M') and it['imp_iva']:
                                subtotal -= Decimal("%.6f" %
                                                    float(it['imp_iva']))
                        # agregar el item si encuadra en la hoja especificada:
                        if k > (hoja - 1) * (lineas_max - 1):
                            if DEBUG:
                                print("it", it)
                            li += 1
                            if it['qty'] is not None:
                                f.set('Item.Cantidad%02d' %
                                      li, self.fmt_qty(it['qty']))
                            if it['codigo'] is not None:
                                f.set('Item.Codigo%02d' % li, it['codigo'])
                            if it['umed'] is not None:
                                if it['umed'] and f.has_key("Item.Umed_ds01"):
                                    # recortar descripción:
                                    umed_ds = self.umeds_ds.get(
                                        int(it['umed']))
                                    s = f.split_multicell(
                                        umed_ds, 'Item.Umed_ds01')
                                    f.set('Item.Umed_ds%02d' % li, s[0])
                            # solo discriminar IVA en A/M (mostrar tasa en B)
                            if letra_fact in ('A', 'M', 'B'):
                                if it.get('iva_id') is not None:
                                    f.set('Item.IvaId%02d' % li, it['iva_id'])
                                    if it['iva_id']:
                                        f.set('Item.AlicuotaIva%02d' %
                                              li, self.fmt_iva(it['iva_id']))
                            if letra_fact in ('A', 'M'):
                                if it.get('imp_iva') is not None:
                                    f.set('Item.ImporteIva%02d' %
                                          li, self.fmt_pre(it['imp_iva']))
                            if it.get('despacho') is not None:
                                f.set('Item.Numero_Despacho%02d' %
                                      li, it['despacho'])
                            if it.get('bonif') is not None:
                                f.set('Item.Bonif%02d' %
                                      li, self.fmt_pre(it['bonif']))
                            f.set('Item.Descripcion%02d' % li, it['ds'])
                            if it['precio'] is not None:
                                f.set('Item.Precio%02d' %
                                      li, self.fmt_pre(it['precio']))
                            if it['importe'] is not None:
                                f.set('Item.Importe%02d' %
                                      li, self.fmt_num(it['importe']))

                            # Datos MTX
                            if it.get('u_mtx') is not None:
                                f.set('Item.U_MTX%02d' % li, it['u_mtx'])
                            if it.get('cod_mtx') is not None:
                                f.set('Item.COD_MTX%02d' % li, it['cod_mtx'])

                            # datos adicionales de items
                            for adic in ['dato_a', 'dato_b', 'dato_c', 'dato_d', 'dato_e']:
                                if adic in it:
                                    f.set('Item.%s%02d' % (adic, li), it[adic])

                    if hojas == hoja:
                        # última hoja, imprimo los totales
                        li += 1

                        # agrego otros tributos
                        lit = 0
                        for it in fact['tributos']:
                            lit += 1
                            if it['desc']:
                                f.set('Tributo.Descripcion%02d' %
                                      lit, it['desc'])
                            else:
                                trib_id = int(it['tributo_id'])
                                trib_ds = self.tributos_ds[trib_id]
                                f.set('Tributo.Descripcion%02d' % lit, trib_ds)
                            if it['base_imp'] is not None:
                                f.set('Tributo.BaseImp%02d' %
                                      lit, self.fmt_num(it['base_imp']))
                            if it['alic'] is not None:
                                f.set('Tributo.Alicuota%02d' %
                                      lit, self.fmt_num(it['alic']) + "%")
                            if it['importe'] is not None:
                                f.set('Tributo.Importe%02d' %
                                      lit, self.fmt_imp(it['importe']))

                        # reiniciar el subtotal neto, independiente de detalles:
                        subtotal = Decimal(0)
                        if fact['imp_neto']:
                            subtotal += Decimal("%.6f" %
                                                float(fact['imp_neto']))
                        # agregar IVA al subtotal si no es factura A
                        if not letra_fact in ('A', 'M') and fact['imp_iva']:
                            subtotal += Decimal("%.6f" %
                                                float(fact['imp_iva']))
                        # mostrar descuento general solo si se utiliza:
                        if 'descuento' in fact and fact['descuento']:
                            descuento = Decimal("%.6f" %
                                                float(fact['descuento']))
                            f.set('descuento', self.fmt_imp(descuento))
                            subtotal -= descuento
                        # al subtotal neto sumo exento y no gravado:
                        if fact['imp_tot_conc']:
                            subtotal += Decimal("%.6f" %
                                                float(fact['imp_tot_conc']))
                        if fact['imp_op_ex']:
                            subtotal += Decimal("%.6f" %
                                                float(fact['imp_op_ex']))
                        # si no se envia subtotal, usar el calculado:
                        if fact.get('imp_subtotal'):
                            f.set('subtotal', self.fmt_imp(
                                fact.get('imp_subtotal')))
                        else:
                            f.set('subtotal', self.fmt_imp(subtotal))

                        # importes generales de IVA y netos gravado / no gravado
                        f.set('imp_neto', self.fmt_imp(fact['imp_neto']))
                        f.set('impto_liq', self.fmt_imp(fact.get('impto_liq')))
                        f.set('impto_liq_nri', self.fmt_imp(
                            fact.get('impto_liq_nri')))
                        f.set('imp_iva', self.fmt_imp(fact.get('imp_iva')))
                        f.set('imp_trib', self.fmt_imp(fact.get('imp_trib')))
                        f.set('imp_total', self.fmt_imp(fact['imp_total']))
                        f.set('imp_subtotal', self.fmt_imp(
                            fact.get('imp_subtotal')))
                        f.set('imp_tot_conc', self.fmt_imp(
                            fact['imp_tot_conc']))
                        f.set('imp_op_ex', self.fmt_imp(fact['imp_op_ex']))

                        # campos antiguos (por compatibilidad hacia atrás)
                        f.set('IMPTO_PERC', self.fmt_imp(
                            fact.get('impto_perc')))
                        f.set('IMP_OP_EX', self.fmt_imp(fact.get('imp_op_ex')))
                        f.set('IMP_IIBB', self.fmt_imp(fact.get('imp_iibb')))
                        f.set('IMPTO_PERC_MUN', self.fmt_imp(
                            fact.get('impto_perc_mun')))
                        f.set('IMP_INTERNOS', self.fmt_imp(
                            fact.get('imp_internos')))

                        # mostrar u ocultar el IVA discriminado si es clase A/B:
                        if letra_fact in ('A', 'M'):
                            f.set('NETO', self.fmt_imp(fact['imp_neto']))
                            f.set('IVALIQ', self.fmt_imp(
                                fact.get('impto_liq', fact.get('imp_iva'))))
                            f.set('LeyendaIVA', "")

                            # limpio etiquetas y establezco subtotal de iva liq.
                            for p in list(self.ivas_ds.values()):
                                f.set('IVA%s.L' % p, "")
                            for iva in fact['ivas']:
                                p = self.ivas_ds[int(iva['iva_id'])]
                                f.set('IVA%s' %
                                      p, self.fmt_imp(iva['importe']))
                                f.set('NETO%s' %
                                      p, self.fmt_imp(iva['base_imp']))
                                f.set('IVA%s.L' % p, "IVA %s" %
                                      self.fmt_iva(iva['iva_id']))
                        else:
                            # Factura C y E no llevan columna IVA (B solo tasa)
                            if letra_fact in ('C', 'E'):
                                f.set('Item.AlicuotaIVA', "")
                            f.set('NETO.L', "")
                            f.set('IVA.L', "")
                            f.set('LeyendaIVA', "")
                            for p in list(self.ivas_ds.values()):
                                f.set('IVA%s.L' % p, "")
                                f.set('NETO%s.L' % p, "")
                        f.set('Total.L', 'Total:')
                        f.set('TOTAL', self.fmt_imp(fact['imp_total']))
                    else:
                        # limpio todas las etiquetas (no es la última hoja)
                        for k in ('imp_neto', 'impto_liq', 'imp_total', 'impto_perc',
                                  'imp_iva', 'impto_liq_nri', 'imp_trib', 'imp_op_ex', 'imp_tot_conc',
                                  'imp_op_ex', 'IMP_IIBB', 'imp_iibb', 'impto_perc_mun', 'imp_internos',
                                  'NGRA.L', 'EXENTO.L', 'descuento.L', 'descuento', 'subtotal.L',
                                  'NETO.L', 'NETO', 'IVA.L', 'LeyendaIVA'):
                            f.set(k, "")
                        for p in list(self.ivas_ds.values()):
                            f.set('IVA%s.L' % p, "")
                            f.set('NETO%s.L' % p, "")
                        f.set('Total.L', 'Subtotal:')
                        f.set('TOTAL', self.fmt_imp(subtotal))

                    f.set('cmps_asoc_ds', cmps_asoc_ds)
                    f.set('permisos_ds', permisos_ds)

                    # Datos del pie de factura (obtenidos desde AFIP):
                    f.set('motivos_ds', motivos_ds)
                    if f.has_key('motivos_ds1') and motivos_ds:
                        if letra_fact in ('A', 'M'):
                            if f.has_key('leyenda_credito_fiscal'):
                                f.set('leyenda_credito_fiscal', msg_no_iva)
                        for i, txt in enumerate(f.split_multicell(motivos_ds, 'motivos_ds1')):
                            f.set('motivos_ds%d' % (i+1), txt)
                    if not motivos_ds:
                        f.set("motivos_ds.L", "")

                    if self.presupuesto:
                        f.set('CAE', fact['cae'])
                        cae = bytes(fact['cae'], encoding='utf')
                        salt = b'@salt-pres-gestionx-' + cae*2;
                        barras = fact['cae'] + str(int(md5(cae + salt).hexdigest(), base=16))[:16]
                        f.set('CodigoBarras', barras)
                        f.set('CodigoBarrasLegible', barras)
                    else:
                        f.set('CAE', fact['cae'])
                        f.set('CAE.Vencimiento', self.fmt_date(fact['fecha_vto']))
                        if fact['cae'] != "NULL" and str(fact['cae']).isdigit() and str(fact['fecha_vto']).isdigit() and self.CUIT:
                            cuit = ''.join(
                                [x for x in str(self.CUIT) if x.isdigit()])
                            barras = ''.join([cuit, "%03d" % int(fact['tipo_cbte']), "%05d" % int(fact['punto_vta']),
                                            str(fact['cae']), fact['fecha_vto']])
                            barras = barras + \
                                self.digito_verificador_modulo10(barras)
                        else:
                            barras = ""

                        f.set('CodigoBarras', barras)
                        f.set('CodigoBarrasLegible', barras)

                        if not HOMO and barras and fact.get("resultado") == 'A':
                            f.set('estado', "Comprobante Autorizado")
                        elif fact.get("resultado") == 'R':
                            f.set('estado', "Comprobante Rechazado")
                        elif fact.get("resultado") == 'O':
                            f.set('estado', "Comprobante Observado")
                        elif fact.get("resultado"):
                            f.set('estado', "Comprobante No Autorizado")
                        else:
                            f.set('estado', "")  # compatibilidad hacia atras

                        # colocar campos de observaciones (si no van en ds)
                        if f.has_key('observacionesgenerales1') and 'obs_generales' in fact:
                            for i, txt in enumerate(f.split_multicell(fact['obs_generales'], 'ObservacionesGenerales1')):
                                f.set('ObservacionesGenerales%d' % (i+1), txt)
                        if f.has_key('observacionescomerciales1') and 'obs_comerciales' in fact:
                            for i, txt in enumerate(f.split_multicell(fact['obs_comerciales'], 'ObservacionesComerciales1')):
                                f.set('ObservacionesComerciales%d' % (i+1), txt)
                        if f.has_key('enletras1') and 'en_letras' in fact:
                            for i, txt in enumerate(f.split_multicell(fact['en_letras'], 'EnLetras1')):
                                f.set('EnLetras%d' % (i+1), txt)

            ret = True
        except Exception as e:
            print(e)
        finally:
            return ret

    def GenerarPDF(self):
        buffer = bytes(self.template.render('', 'S'), encoding='latin-1')
        return buffer
