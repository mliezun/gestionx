<?php

namespace common\components;

use GuzzleHttp\Client;
use yii\web\HttpException;
use afipsdk;
use Yii;

class AfipHelper
{
    public static function ImprimirComprobante($datos)
    {
        // Normalizo los datos de la venta para enviar a AFIP
        $datosAfip = self::datosAfip($datos);

        $params = Yii::$app->session->get('Parametros');

        // Envío los datos de la venta a AFIP
        $resultado = self::altaComprobante([
            'CUIT' => $params['CUIT'],
            'cert' => $params['AFIPCERT'],
            'key' => $params['AFIPKEY'],
            'Comprobante' => $datosAfip
        ]);
        // TODO: verificar resultado
        $resultado = self::datosResultado($resultado);

        // Agrego los datos de los artículos para generar pdf
        $datosAfip['Articulos'] = json_decode($datos['Articulos'], true);

        // Normalizo los datos para generar pdf
        $datosPdf = self::datosPdf($datosAfip);

        // Genero archivo pdf
        return self::generarPDF($datosPdf, $resultado);
    }

    /**
     * Retorna los datos necesarios para mandar al WS de la AFIP.
     */
    private static function datosAfip($datos)
    {
        $datosAfip = [
            // Cantidad de comprobantes a registrar
            'CantReg' 	=> 1,
            // Punto de venta
            'PtoVta' 	=> $datos['IdPuntoVenta'],
            // Tipo de comprobante (ver tipos disponibles) 
            'CbteTipo' 	=> $datos['IdTipoComprobanteAfip'],
            // Concepto del Comprobante: (1)Productos, (2)Servicios, (3)Productos y Servicios
            'Concepto' 	=> 1,
            // Tipo de documento del comprador (99 consumidor final, ver tipos disponibles)
            'DocTipo' 	=> $datos['IdTipoDocAfip'],
            // Número de documento del comprador (0 consumidor final)
            'DocNro' 	=> $datos['Documento'],
            // Número de comprobante o numero del primer comprobante en caso de ser mas de uno
            'CbteDesde' 	=> $datos['IdVenta'],
            // Número de comprobante o numero del último comprobante en caso de ser mas de uno
            'CbteHasta' 	=> $datos['IdVenta'],
            // (Opcional) Fecha del comprobante (yyyymmdd) o fecha actual si es nulo
            'CbteFch' 	=> intval(date('Ymd')),
            // Importe total del comprobante
            'ImpTotal' 	=> $datos['Monto'],
            // Importe neto no gravado
            'ImpTotConc' 	=> 0,
            // Importe neto gravado
            'ImpNeto' 	=> 0,
            // Importe exento de IVA
            'ImpOpEx' 	=> 0,
            //Importe total de IVA
            'ImpIVA' 	=> 0,
            //Importe total de tributos
            'ImpTrib' 	=> 0,
            //Tipo de moneda usada en el comprobante (ver tipos disponibles)('PES' para pesos argentinos) 
            'MonId' 	=> 'PES',
            // Cotización de la moneda usada (1 para pesos argentinos)  
            'MonCotiz' 	=> 1,
            // (Opcional) Alícuotas asociadas al comprobante
            // 'Iva' 		=> [], 
        ];

        $articulos = json_decode($datos['Articulos'], true);

        $ivas = [];

        $importeIVA = 0;

        foreach ($articulos as $articulo) {
            $idTipoIva = $articulo['IdTipoIVA'];
            if (!array_key_exists($idTipoIva, $ivas)) {
                $ivas[$idTipoIva] = [
                    'Id' => $idTipoIva,
                    'BaseImp' => 0,
                    'Importe' => 0
                ];
            }
            $ivas[$idTipoIva]['BaseImp'] += $articulo['Subtotal'];
            $ivas[$idTipoIva]['Importe'] += $articulo['ImporteIVA'];
            $importeIVA += $articulo['ImporteIVA'];
        }

        $datosAfip['ImpNeto'] = $datos['Total'];
        $datosAfip['ImpTrib'] = 0;

        /*
        foreach ($ivas as $id => $iva) {
            $datosAfip['Iva'][] = $iva;
        }
        */

        return $datosAfip;
    }

    private static function datosPdf($datos)
    {
        return NinjaArrayHelper::normalizar($datos, [
            'CbteTipo' => 'tipo_cbte',
            'PtoVta' => 'punto_venta',
            'Concepto' => 'concepto',
            'DocTipo' => 'tipo_doc',
            'DocNro' => 'nro_doc',
            'CbteDesde' => 'cbte_nro',
            'ImpTotal' => 'imp_total',
            'ImpTotConc' => 'imp_tot_conc',
            'ImpNeto' => 'imp_neto',
            'ImpIVA' => 'imp_iva',
            'ImpTrib' => 'imp_trib',
            'ImpOpEx' => 'imp_op_ex',
            'CbteFch' => 'fecha_cbte',
            'MonId' => 'moneda_id',
            'MonCotiz' => 'moneda_ctz',
            'Articulos' => [
                'items',
                [
                    'Articulo' => 'ds',
                    'Codigo' => 'codigo',
                    'Cantidad' => 'qty',
                    'Precio' => 'precio',
                    'Subtotal' => 'importe',
                    'ImporteIVA' => 'imp_iva',
                    'IdTipoIVA' => 'iva_id',
                    'Unidad' => 'umed'
                ]
            ],
            'Iva' => [
                'subtotales_iva',
                [
                    'Id' => 'iva_id',
                    'BaseImp' => 'base_imp',
                    'Importe' => 'importe'
                ]
            ]
        ]);
    }

    private static function datosResultado($resultado)
    {
        $resultado = json_decode(json_encode($resultado), true);
        return NinjaArrayHelper::normalizar($resultado, [
            'CAE' => 'cae',
            'CodAutorizacion' => 'cae',
            'FchVto' => 'fch_venc_cae'
        ]);
    }


    /**
     * Generación de comprobante de AFIP.
     * Referencia: https://github.com/mliezun/eratospdf
     */
    private static function generarPDF($datos, $resultado)
    {
        $json = array_merge($datos, $resultado);
        $json['fecha'] = date('Ymd');
        $json['fecha_cbte'] = "{$json['fecha_cbte']}";
        $json['subtotales_iva'] = [];
        $json['idioma_cbte'] = 1;

        $params = Yii::$app->session->get('Parametros');

        $json['conf_pdf'] = [
            // 'LOGO' => $params['LOGO'],
            'EMPRESA' => $params['EMPRESA'],
            //'MEMBRETE1' => '',
            //'MEMBRETE2' => '',
            'CUIT' => 'CUIT ' . $params['CUIT'],
            //'IIBB' => '',
            'IVA' => 'IVA Responsable Inscripto',
            //'INICIO' => '',
            //'BORRADOR' => ''
        ];

        /*
        LOGO=logo.png
        EMPRESA=Mariano Reingart
        MEMBRETE1=Profesor Castagna 4942
        MEMBRETE2=Capital Federal
        CUIT=CUIT 20-26756539-3
        IIBB=IIBB 20-26756539-3
        IVA=IVA Responsable Inscripto
        INICIO=Inicio de Actividad: 01/04/2006
        BORRADOR=HOMOLOGACION
        */

        $client = new Client();
        $response = $client->request('POST', 'http://127.0.0.1:5000/api/v1/pdf', [
            'json' => $json
        ]);

        return $response->getBody();
    }

    /**
     * Alta idempotente de comprobante de AFIP.
     */
    private static function altaComprobante($datos)
    {
        $tmp_cert = tmpfile();
        $meta_data = stream_get_meta_data($tmp_cert);
        $tmp_cert_path = $meta_data["uri"];

        $tmp_key = tmpfile();
        $meta_data = stream_get_meta_data($tmp_key);
        $tmp_key_path = $meta_data["uri"];

        if (dirname($tmp_key_path) != dirname($tmp_cert_path)) {
            throw new HTTPException(500, "Error en la generación de certificados de AFIP");
        }

        fwrite($tmp_cert, $datos['cert']);
        fwrite($tmp_key, $datos['key']);

        $tmp_folder = dirname($tmp_key_path) . '/';
        $tmp_cert_file = basename($tmp_cert_path);
        $tmp_key_file = basename($tmp_key_path);

        $afip = new \Afip([
            'CUIT' => $datos['CUIT'],
            'cert' => $tmp_cert_file,
            'key' => $tmp_key_file,
            'res_folder' => $tmp_folder,
            'ta_folder' => '/var/www/certs/'
        ]);

        // Yii::info(json_encode($afip->ElectronicBilling->GetVoucherTypes()));

        $comprobante = $datos['Comprobante'];

        $cbteAfip = $afip->ElectronicBilling->GetVoucherInfo($comprobante['CbteDesde'], $comprobante['PtoVta'], $comprobante['CbteTipo']);

        if (!isset($cbteAfip)) {
            $res = $afip->ElectronicBilling->CreateNextVoucher($comprobante);
        } else {
            $res = $cbteAfip;
        }

        // Borra los archivos temporales
        fclose($tmp_cert);
        fclose($tmp_key);

        return $res;
    }
}
