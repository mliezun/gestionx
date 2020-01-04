<?php

namespace common\components;

use GuzzleHttp\Client;
use Yii;
use yii\web\HttpException;

/**
 * Clase auxiliar para implementar las funciones que el SDK de PHP de Paypal no tiene.
 */
class PaypalApi
{
    public $token;

    public function __construct()
    {
        $user = Yii::$app->params['paypal']['CLIENT_ID'];
        $pass = Yii::$app->params['paypal']['SECRET'];
        $token = base64_encode("{$user}:{$pass}");
        
        $cache_key = "paypal-$token";
        $cached_token = Yii::$app->cache->get($cache_key);
        if (!$cached_token) {
            $res = $this->sendRequest("POST", "/v1/oauth2/token", [
                'headers' => [
                    'Authorization' => "Basic {$token}",
                    'Content-Type' => 'application/x-www-form-urlencoded'
                ],
                'form_params' => [
                    'grant_type' => 'client_credentials'
                ]
            ]);
            Yii::$app->cache->set($cache_key, $res['access_token'], $res['expires_in'] - 5 * 60);
            $cached_token = $res['access_token'];
        }
        
        $this->token = $cached_token;
    }

    /**
     * Envía un request a la API de Paypal.
     *
     * @param $verb Verbo HTTP
     * @param $url URL del request
     * @param $data Datos del request
     */
    private function sendRequest(string $verb, string $url, array $data = [])
    {
        $base = 'https://api.sandbox.paypal.com';

        if (Yii::$app->params['paypal']['MODE'] == 'live') {
            $base = 'https://api.paypal.com';
        }

        $client = new Client([
            'base_uri' => $base
        ]);

        $request = [
            'headers' => ['Content-Type' => 'application/json'],
            'json' => $data
        ];

        if (array_key_exists('headers', $data)) {
            $request = $data;
        }

        if (isset($this->token)) {
            $request['headers']['Authorization'] = "Bearer {$this->token}";
        }

        if (array_key_exists('json', $request) && count($request['json']) == 0) {
            unset($request['json']);
        }
        try {
            $response = $client->request($verb, $url, $request);
            Yii::info($verb . ': ' . $base . $url);
        } catch (\Exception $e) {
            Yii::error($verb . ': ' . $base . $url);
            Yii::error(json_decode($response->getBody(), true));
            throw new HttpException(500, "Error en el request a Paypal");
        }
        
        $jsonResp = json_decode($response->getBody(), true);
        return $jsonResp;
    }

    /**
     * Retorna un listado de planes de Paypal.
     * Referencia: https://developer.paypal.com/docs/api/subscriptions/v1/#plans_list
     *
     */
    public function listarPlanes()
    {
        return $this->sendRequest('GET', '/v1/billing/plans', array())['plans'];
    }

    /**
     * Obtiene el nombre de un Plan (es el mismo nombre usado en MySQL) a partir del Id
     *
     * @param Id Identificador del Plan en Paypal
     */
    public function getPlanName($Id = '')
    {
        $planes = $this->listarPlanes();
        
        foreach ($planes as $plan) {
            if ($plan['id'] === $Id) {
                return $plan['name'];
            }
        }

        return null;
    }

    /**
     * Obtiene el Id de un Plan de Paypal a través del Nombre
     *
     * @param Nombre Nombre único del plan en MySQL
     */
    public function getPlanId($Nombre = '')
    {
        if (array_key_exists('PLAN_ID', Yii::$app->params['paypal'])) {
            return Yii::$app->params['paypal']['PLAN_ID'];
        }
        $planes = $this->listarPlanes();
        
        foreach ($planes as $plan) {
            if ($plan['name'] === $Nombre) {
                return $plan['id'];
            }
        }

        return null;
    }

    /**
     * Alta de suscripción a un Plan en Paypal. La crea en estado pendiente de aprobación.
     * Referencia: https://developer.paypal.com/docs/api/subscriptions/v1/#subscriptions_create
     *
     * @param IdSuscripcion Identificador único de una suscripción. Usado para idempotencia
     * @param Plan Nombre del Plan al que se desea suscribir
     */
    public function crearSuscripcion($IdSuscripcion, $Plan = '')
    {
        if (strpos(Yii::$app->params['appUrl'], 'localhost')) {
            $returnUrl = 'https://gestionx.forta.xyz';
            $cancelUrl = 'https://gestionx.forta.xyz';
        } else {
            $returnUrl = Yii::$app->params['appUrl'] . 'paypal';
            $cancelUrl = Yii::$app->params['appUrl'] . 'billing';
        }

        $data = [
            'headers' => [
                'PayPal-Request-Id' => $IdSuscripcion,
                'Prefer' => 'return=representation',
                'Accept' => 'application/json'
            ],
            'json' => [
                'plan_id' => $this->getPlanId($Plan),
                'start_time' => date("Y-m-d\TH:i:s\Z", strtotime('tomorrow')),
                'auto_renewal' => true,
                'application_context' => [
                    'brand_name' => 'ExpenseTKR',
                    'locale' => 'en-US',
                    'user_action' => 'SUBSCRIBE_NOW',
                    'payment_method' => [
                        'payer_selected' => 'PAYPAL',
                        'payee_preferred' => 'IMMEDIATE_PAYMENT_REQUIRED'
                    ],
                    'return_url' => $returnUrl,
                    'cancel_url' => $cancelUrl
                ]
            ]
        ];

        return $this->sendRequest('POST', '/v1/billing/subscriptions', $data);
    }

    /**
     * Retorna los datos de una suscripción.
     * Referencia: https://developer.paypal.com/docs/api/subscriptions/v1/#subscriptions_get
     *
     * @param subscription_id Identificador de la suscripción en Paypal
     */
    public function obtenerSuscripcion($subscription_id)
    {
        return $this->sendRequest('GET', '/v1/billing/subscriptions/' . $subscription_id);
    }

    /**
     * Cancela una suscripción.
     * Referencia: https://developer.paypal.com/docs/api/subscriptions/v1/#subscriptions_cancel
     *
     * @param subscription_id Identificador de la suscripción en Paypal
     */
    public function cancelarSuscripcion($subscription_id)
    {
        return $this->sendRequest('POST', '/v1/billing/subscriptions/' . $subscription_id . '/cancel');
    }

    /**
     * Permite verificar la firma del webhook para saber si el request es válido.
     * Referencia: https://developer.paypal.com/docs/api/webhooks/v1/#verify-webhook-signature
     *
     * @param array data
     */
    public function verificarWebhook($data)
    {
        return $this->sendRequest('POST', '/v1/notifications/verify-webhook-signature', $data);
    }
}
