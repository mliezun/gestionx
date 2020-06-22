import os
from sanic import Sanic, response
from configparser import ConfigParser
from fepdf import FEPDF, CONFIG_FILE

config = ConfigParser()
config.read(CONFIG_FILE)
conf_fact = dict(config.items('FACTURA'))

app = Sanic()


@app.route('/api/v1/pdf', methods=['POST'])
async def generatePdf(request):
    input_json = request.json

    esPresupuesto = 'PRESUPUESTO' in input_json['conf_pdf']
    template = 'presupuesto.csv' if esPresupuesto else 'factura.csv'

    fepdf = FEPDF(esPresupuesto)
    # cargo el formato CSV por defecto (factura.csv)
    await fepdf.CargarFormato(template)
    # establezco formatos (cantidad de decimales) según configuración:
    fepdf.FmtCantidad = conf_fact.get("fmt_cantidad", "0.2")
    fepdf.FmtPrecio = conf_fact.get("fmt_precio", "0.2")

    fepdf.CrearFactura(**input_json)

    for k in ('localidad_cliente', 'provincia_cliente', 'custom-nro-cli', 'custom-pedido', 'custom-remito', 'custom-transporte'):
        if k in input_json:
            fepdf.EstablecerParametro(k, input_json[k])

    if not esPresupuesto:
        if 'comprobantes_asociados' in input_json:
            for cmp in input_json['comprobantes_asociados']:
                fepdf.AgregarCmpAsoc(**cmp)

        if 'tributos_adicionales' in input_json:
            for tributo in input_json['tributos_adicionales']:
                fepdf.AgregarTributo(**tributo)

        if 'subtotales_iva' in input_json:
            for iva in input_json['subtotales_iva']:
                fepdf.AgregarIva(**iva)

    if 'items' in input_json:
        for item in input_json['items']:
            fepdf.AgregarDetalleItem(**item)

    # Comprobante Autorizado
    fepdf.EstablecerParametro("resultado", "A")

    # Agrego datos de configuración
    for (k, v) in input_json['conf_pdf'].items():
        fepdf.AgregarDato(k, v)
        if k.upper() == 'CUIT':
            fepdf.CUIT = v  # CUIT del emisor para código de barras

    fepdf.CrearPlantilla(papel=conf_fact.get("papel", "legal"),
                         orientacion=conf_fact.get("orientacion", "portrait"))

    fepdf.ProcesarPlantilla(num_copias=int(conf_fact.get("copias", 1)),
                            lineas_max=int(conf_fact.get("lineas_max", 24)),
                            qty_pos=conf_fact.get("cant_pos") or 'izq')

    async def streaming_fn(response):
        await response.write(fepdf.GenerarPDF())

    return response.stream(streaming_fn, headers={'Content-Disposition': f'inline; filename=out.pdf'}, content_type='application/pdf')


@app.route('/api/v1/')
async def helloV1(request):
    return response.text('Hello v1')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, access_log=False)
