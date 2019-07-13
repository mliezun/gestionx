<?php

namespace common\components;

class AfipHelper
{
    public static function generarPDF($datos)
    {
        $client = new \GuzzleHttp\Client();
        $response = $client->request('POST', 'http://127.0.0.1:5000/api/v1/pdf', [
            'json' => $datos
        ]);

        return $response->getBody();
    }
}
