<?php

namespace common\components;

use GuzzleHttp\Client;
use yii\web\HttpException;
use afipsdk;
use Yii;

class ComprobanteHelper
{
    public static function ImprimirComprobante($params, $datos, $esAfip = true)
    {
        // Normalizo los datos de la venta para enviar a AFIP
        $datosAfip = self::datosAfip($datos);

        $esProd = $params['AFIPMODOHOMO'] == 'N';

        // Envío los datos de la venta a AFIP
        if ($esAfip) {
            $resultado = self::altaComprobante([
                'CUIT' => $params['CUIT'],
                'cert' => $esProd ? $params['AFIPCERT'] : $params['AFIPCERTHOMO'],
                'key' => $params['AFIPKEY'],
                'Comprobante' => $datosAfip
            ], $esProd);
            $resultado = self::datosResultado($resultado);
        } else {
            $idempresa = Yii::$app->user->identity->IdEmpresa;
            $cae = $idempresa . str_pad("{$datos['IdVenta']}", 16 - strlen($idempresa), '0', STR_PAD_LEFT);
            $resultado = ['cae' => $cae];
        }

        // Agrego los datos de los artículos para generar pdf
        $datosAfip['Articulos'] = json_decode($datos['Articulos'], true);

        // Normalizo los datos para generar pdf
        $datosPdf = self::datosPdf($datosAfip);
        $datosCliente = self::datosCliente($datos);

        // Genero archivo pdf
        return self::generarPDF($params, $datosPdf, $datosCliente, $resultado, $esAfip);
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
            'PtoVta' 	=> $datos['NroPuntoVenta'] ?? $datos['IdPuntoVenta'],
            // Tipo de comprobante (ver tipos disponibles)
            'CbteTipo' 	=> $datos['IdTipoComprobanteAfip'],
            // Concepto del Comprobante: (1)Productos, (2)Servicios, (3)Productos y Servicios
            'Concepto' 	=> 1,
            // Tipo de documento del comprador (99 consumidor final, ver tipos disponibles)
            'DocTipo' 	=> $datos['IdTipoDocAfip'],
            // Número de documento del comprador (0 consumidor final)
            'DocNro' 	=> $datos['Documento'],
            // Número de comprobante o numero del primer comprobante en caso de ser mas de uno
            'CbteDesde' 	=> $datos['IdComprobanteAfip'],
            // Número de comprobante o numero del último comprobante en caso de ser mas de uno
            'CbteHasta' 	=> $datos['IdComprobanteAfip'],
            // (Opcional) Fecha del comprobante (yyyymmdd) o fecha actual si es nulo
            'CbteFch' 	=> FechaHelper::fechaAfip($datos['FechaGenerado']),
            // Importe total del comprobante
            'ImpTotal' 	=> $datos['Total'],
            // Importe neto no gravado
            'ImpTotConc' 	=> 0,
            // Importe neto gravado
            'ImpNeto' 	=> $datos['Total'],
            // Importe exento de IVA
            'ImpOpEx' 	=> 0,
            //Importe total de IVA
            'ImpIVA' 	=> 0,
            //Importe total de tributos
            'ImpTrib' 	=> 0,
            //Tipo de moneda usada en el comprobante (ver tipos disponibles)('PES' para pesos argentinos)
            'MonId' 	=> 'PES',
            // Cotización de la moneda usada (1 para pesos argentinos)
            'MonCotiz' 	=> 1
        ];

        $datosCliente = json_decode($datos['Datos'], true);

        if (array_key_exists('CUIT', $datosCliente) && isset($datosCliente['CUIT'])) {
            $datosAfip['DocTipo'] = 80;
            $datosAfip['DocNro'] = $datosCliente['CUIT'];
        }

        // Devuelta
        if ($datos['Estado'] === 'D') {
            $comprobanteOrig = json_decode($datos['ComprobanteAfipOriginal'], true);
            $datosAfip['CbtesAsoc'] = [
                [
                    'Tipo' => $comprobanteOrig['IdTipoComprobanteAfip'],
                    'PtoVta' => $datos['IdPuntoVenta'],
                    'Nro' => $comprobanteOrig['IdComprobanteAfip'],
                    'CbteFch' => FechaHelper::fechaAfip($comprobanteOrig['FechaGenerado']),
                ]
            ];
        }

        $articulos = json_decode($datos['Articulos'], true);

        // Listado de ivas por artículo para inclusión opcional en la factura
        $ivas = [];
        // Monto total del importe de iva para inclusión opcional en la factura
        $importeIVA = 0;

        // Calculo los montos de iva por artículo
        foreach ($articulos as $articulo) {
            $idTipoIva = $articulo['IdTipoIVA'];
            if (!array_key_exists($idTipoIva, $ivas)) {
                $ivas[$idTipoIva] = [
                    'Id' => $idTipoIva,
                    'BaseImp' => 0,
                    'Importe' => 0
                ];
            }
            $ivas[$idTipoIva]['BaseImp'] += $articulo['Subtotal'] - $articulo['ImporteIVA'];
            $ivas[$idTipoIva]['Importe'] += $articulo['ImporteIVA'];
            $importeIVA += $articulo['ImporteIVA'];
        }

        // Agrego IVA en los siguientes casos
        // Factura A (1), B (6) o M (51)
        // Nota de Crédito A (3), B (8), M (53)
        if (\in_array($datos['IdTipoComprobanteAfip'], [1, 6, 51, 3, 8, 53])) {
            $datosAfip['Iva'] = array();
            foreach ($ivas as $id => $iva) {
                $datosAfip['Iva'][] = $iva;
            }
            $datosAfip['ImpNeto'] = number_format($datosAfip['ImpNeto'] - $importeIVA, 2, '.', '');
            $datosAfip['ImpIVA'] = number_format($importeIVA, 2, '.', '');
        }

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
                    'Descripcion' => 'ds',
                    'Articulo' => 'codigo',
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
            ],
            'CbtesAsoc' => [
                'comprobantes_asociados',
                [
                    'Tipo' => 'tipo',
                    'PtoVta' => 'pto_vta',
                    'Nro' => 'nro'
                ]
            ]
        ]);
    }

    private static function datosCliente($datos)
    {
        $datos = array_merge($datos, json_decode($datos['Datos'], true));
        return NinjaArrayHelper::normalizar($datos, [
            'NombreCliente' => 'nombre_cliente',
            'Direccion' => 'domicilio_cliente',
            'Provincia' => 'provincia_cliente',
            'Localidad' => 'localidad_cliente'
        ]);
    }

    private static function datosResultado($resultado)
    {
        $resultado = json_decode(json_encode($resultado), true);
        return NinjaArrayHelper::normalizar($resultado, [
            'CAE' => 'cae',
            'CodAutorizacion' => 'cae',
            'FchVto' => 'fch_venc_cae',
            'CAEFchVto' => 'fch_venc_cae'
        ]);
    }


    /**
     * Generación de comprobante de AFIP.
     * Referencia: https://github.com/mliezun/eratospdf
     */
    private static function generarPDF($params, $datosPdf, $datosCliente, $resultado, $esAfip = true)
    {
        $json = array_merge($datosPdf, $datosCliente, $resultado);
        $json['fecha'] = date('Ymd');
        $json['fecha_cbte'] = "{$json['fecha_cbte']}";
        $json['idioma_cbte'] = 1;

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

        if (!$esAfip) {
            $json['conf_pdf']['PRESUPUESTO'] = true;
            $json['tipo_cbte'] = 11;
        }

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
    private static function altaComprobante($datos, $esProd = false)
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
            'ta_folder' => '/var/www/certs/',
            'production' => $esProd
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
