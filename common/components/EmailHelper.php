<?php

namespace common\components;

use Http\Adapter\Guzzle6\Client;
use Mailgun\Mailgun;
use Yii;
use yii\web\HttpException;

class EmailHelper
{
    const DOMAIN = 'mg.forta.xyz';
    const API_KEY = 'key-86e3960b287c7e297c5347935ba736f5';

    /**
     * Envia un email al destinatario usando la configuracion establecida en EmailHelper.
     *
     * Ejemplo: enviarEmail('Usuario <usuario@ejemplo.com>', 'Bienvenido a $EMPRESA',
     *          'bienvenida', [
     *                  'user' => 'Usuario'
     *          ]);
     *
     * @param string $from Emisor del email
     * @param string $dest Destinatario del email
     * @param string $asunto Asunto del email
     * @param string $view Vista a renderizar en @common/email
     * @param array $params Parametros que se le pasaran a la vista
     * @param array $attachment Opcional: Ruta del archivo adjunto que se desea enviar
     */
    public static function enviarEmail(string $from, string $dest, string $asunto, string $view, array $params, string $attachment = null)
    {
        $client = new Client();
        $mailgun = new Mailgun(EmailHelper::API_KEY, $client);
        $domain = EmailHelper::DOMAIN;
        $msg = [
            'from' => $from,
            'to' => $dest,
            'subject' => $asunto,
            'html' => Yii::$app->controller->renderPartial('@common/mail/' . $view, $params)
        ];
        if ($attachment != null) {
            $result = $mailgun->sendMessage($domain, $msg, [ 'attachment' => [$attachment] ]);
        } else {
            $result = $mailgun->sendMessage($domain, $msg);
        }
        $responseCode = $result->http_response_code;
        if ($responseCode != '200') {
            throw new HttpException($responseCode, 'Ocurrió un error al intentar enviar un correo a la dirección indicada.');
        }
    }
}
