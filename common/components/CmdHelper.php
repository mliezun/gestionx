<?php

namespace common\components;

use GuzzleHttp\Client;

class CmdHelper
{
    /**
     * Permite ejecutar un listado de comandos. Devuelve OK en caso de éxito, NOK en caso de error.
     */
    public static function exec($cmds)
    {
        $client = new Client();
        $response = $client->request('POST', 'http://127.0.0.1:3000/', [
            'json' => [
                'cmds' => $cmds
            ]
        ]);

        return $response->getBody();
    }
}
