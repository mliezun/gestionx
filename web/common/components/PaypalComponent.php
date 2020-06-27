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

    /*
    public function altaPlan(Planes $plan)
    {
        $paypal_plan = new Plan();

        $paypal_plan->setName($plan->Plan)
            ->setDescription($plan->Descripcion)
            ->setType('fixed');

        $paymentDefinition = new PaymentDefinition();

        $freq = 'MONTH';

        switch (intval($plan->CantDias)) {
            case 365:
                $freq = 'YEAR';
                break;
            case 30:
                $freq = 'MONTH';
                break;
            case 7:
                $freq = 'WEEK';
                break;
            case 1:
                $freq = 'DAY';
                break;
            default:
                $freq = 'MONTH';
                break;
        }

        $paymentDefinition->setName('Regular Payments')
            ->setType('REGULAR')
            ->setFrequency($freq)
            ->setFrequencyInterval("2")
            ->setCycles("999")
            ->setAmount(new Currency(array('value' => $plan->Precio, 'currency' => 'USD')));

        $merchantPreferences = new MerchantPreferences();

        $merchantPreferences
            //->setReturnUrl("$baseUrl/ExecuteAgreement.php?success=true")
            //->setCancelUrl("$baseUrl/ExecuteAgreement.php?success=false")
            ->setAutoBillAmount("yes")
            ->setInitialFailAmountAction("CONTINUE")
            ->setMaxFailAttempts("3");

        $paypal_plan->setPaymentDefinitions(array($paymentDefinition));
        $paypal_plan->setMerchantPreferences($merchantPreferences);

        try {
            $output = $paypal_plan->create(self::getContext());
        } catch (Exception $ex) {
            Yii::error($plan->Plan, 'Error alta plan');
        }

        return $output;
    }
    */
}
