<?php

namespace common\components;

use common\models\Planes;

use Yii;
use yii\console\Exception;

class PaypalComponent
{
    /**
     * Da de alta una suscripción en paypal. La crea en estado pendiente de aprobación.
     * Retorna id de la suscripción y el link para redirigir al cliente a la ventana de pago.
     *
     * @param IdSuscripcion Identificador único de una suscripción. Usado para idempotencia
     * @param Plan Nombre del Plan al que se desea suscribir
     */
    public function crearSuscripcion($IdSuscripcion, $Plan = '')
    {
        $api = new PaypalApi();

        $request = $api->crearSuscripcion($IdSuscripcion, $Plan);
        $link = '';
        foreach ($request['links'] as $l) {
            if ($l['rel'] == 'approve') {
                $link = $l['href'];
                break;
            }
        }
        return [
            'id' => $request['id'],
            'link' => $link
        ];
    }

    /**
     * Retorna los datos de una suscripción.
     * Referencia: https://developer.paypal.com/docs/api/subscriptions/v1/#subscriptions_get
     *
     * @param subscription_id Identificador de la suscripción en Paypal
     */
    public function obtenerSuscripcion($suscription_id)
    {
        $api = new PaypalApi();

        return $api->obtenerSuscripcion($suscription_id);
    }

    /**
     * Cancela una suscripción.
     * Referencia: https://developer.paypal.com/docs/api/subscriptions/v1/#subscriptions_cancel
     *
     * @param subscription_id Identificador de la suscripción en Paypal
     */
    public function cancelarSuscripcion($subscription_id)
    {
        $api = new PaypalApi();

        return $api->cancelarSuscripcion($subscription_id);
    }

    /**
     * Verifica que el webhook tenga la firma correcta.
     * Si no es correcta tira una excepción.
     *
     */
    public static function verificarWebhook()
    {
        $api = new PaypalApi();
        
        $headers = Yii::$app->request->headers;
        $body = Yii::$app->request->post();
        $webhookID = Yii::$app->params['paypal']['WEBHOOK_ID'];

        $data = [
            'auth_algo' => $headers->get('PAYPAL-AUTH-ALGO'),
            'cert_url' => $headers->get('PAYPAL-CERT-URL'),
            'transmission_id' => $headers->get('PAYPAL-TRANSMISSION-ID'),
            'transmission_sig' => $headers->get('PAYPAL-TRANSMISSION-SIG'),
            'transmission_time' => $headers->get('PAYPAL-TRANSMISSION-TIME'),
            'webhook_id' => $webhookID,
            'webhook_event' => $body
        ];

        return $api->verificarWebhook($data);
    }
}
