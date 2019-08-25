<?php

namespace common\components;

use GuzzleHttp\Client;
use yii\web\HttpException;
use afipsdk;
use Yii;

class AfipHelper
{
    /**
     * Generación de comprobante de AFIP.
     * Referencia: https://github.com/mliezun/eratospdf
     */
    public static function generarPDF($datos)
    {
        $client = new Client();
        $response = $client->request('POST', 'http://127.0.0.1:5000/api/v1/pdf', [
            'json' => $datos
        ]);

        return $response->getBody();
    }

    /**
     * Alta idempotente de comprobante de AFIP.
     */
    public static function altaComprobante($datos)
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

        Yii::info(json_encode($afip->ElectronicBilling->GetVoucherTypes()));

        $cbte = $afip->ElectronicBilling->GetVoucherInfo($datos['CbteDesde'], $datos['PtoVta'], $datos['CbteTipo']);

        if (isset($cbte)) {
            $res = $afip->ElectronicBilling->CreateVoucher($datos['Comprobante']);
        } else {
            $res = $cbte;
        }

        // Borra los archivos temporales
        fclose($tmp_cert);
        fclose($tmp_key);

        return $res;
    }
}
