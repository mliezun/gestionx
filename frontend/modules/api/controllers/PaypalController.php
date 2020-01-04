<?php
namespace frontend\modules\api\controllers;

use Yii;
use yii\helpers\ArrayHelper;
use yii\web\HttpException;
use frontend\modules\api\filters\auth\OptionalBearerAuth;
use common\components\PaypalComponent;
use common\models\GestorSuscripciones;
use common\models\Suscripciones;
use common\models\SuscripcionesPaypal;
use common\models\IOperacionesSuscripciones;
use common\models\Planes;
use common\models\LogRequest;

class PaypalController extends BaseController
{
    public function behaviors()
    {
        return ArrayHelper::merge(
            parent::behaviors(),
            [
                'bearerAuth' => [
                    'class' => OptionalBearerAuth::className(),
                    'except' => ['webhook', 'options'],
                ],
            ]
        );
    }
    
    /**
     * @api {post} /paypal Finaliza Suscripción
     * @apiName SuscripcionPaypal
     * @apiGroup Suscripciones
     * @apiPermission logueado
     *
     * @apiParam {String} subscription_id Identificador de la suscripción en Paypal
     *
     * @apiError {String} Error Mensaje de error.
     */
    public function actionCreate()
    {
        $subscription_id = Yii::$app->request->post('subscription_id');
        
        $estrategia = new SuscripcionesPaypal;

        return $estrategia->Finaliza($subscription_id);
    }

    /**
     * Esta acción retorna los siguientes códigos de estado:
     *      200 si es exitosa.
     *      400 si el mensaje no se verifica correctamente.
     *      500 si no se pudo procesar el mensaje.
     * Paypal reintenta 25 veces a lo largo de 3 días mientras no reciba un código de estado 200.
     */
    public function actionWebhook()
    {
        try {
            LogRequest::Log('/paypal/webhook', [
                'Body' => Yii::$app->request->post(),
                'Headers' => Yii::$app->request->headers,
                'Tipo' => 'AntesVerificar'
            ]);
            PaypalComponent::verificarWebhook();
    
            LogRequest::Log('/paypal/webhook', [
                'Body' => Yii::$app->request->post(),
                'Tipo' => 'DespuesVerificar'
            ]);
    
            $tipo = Yii::$app->request->post('event_type');
            $resource = Yii::$app->request->post('resource');
    
            $resultado = 'ERROR';
    
            if ($tipo === 'BILLING.SUBSCRIPTION.CANCELLED') {
                $susc = new Suscripciones;
                $susc->Datos = [
                    'Proveedor' => IOperacionesSuscripciones::PAYPAL,
                    'Mensaje' => $resource,
                    'Tipo' => 'W'
                ];
                $susc->DamePorDatos();
                $gestor = new SuscripcionesPaypal;
                $resultado = $gestor->Cancelar($susc, 'W');
            } elseif ($tipo === 'BILLING.SUBSCRIPTION.UPDATED') {
                $gestor = new GestorSuscripciones;
                $resultado = $gestor->FinAltaSuscripcion([
                    'Proveedor' => self::PAYPAL,
                    'Tipo' => 'W', // Webhook Paypal
                    'Mensaje' => $resource
                ]);
            } elseif ($tipo === 'BILLING.SUBSCRIPTION.ACTIVATED') {
                $gestor = new SuscripcionesPaypal;
                $resultado = $gestor->Finaliza($resource['id']);
            }
    
            LogRequest::Log('/paypal/webhook', [
                'Body' => Yii::$app->request->post(),
                'Tipo' => 'DespuesSwitch',
                'Resultado' => $resultado
            ]);
    
            if (gettype($resultado) == 'array') {
                if (isset($resultado['Error'])) {
                    throw new HttpException('500', 'Internal Server Error');
                }
            } elseif (substr($resultado, 0, 2) != 'OK') {
                throw new HttpException('500', 'Internal Server Error');
            }
        } catch (\Exception $e) {
            LogRequest::Log('/paypal/webhook', [
                'Body' => Yii::$app->request->post(),
                'Excepcion' => $e->getTraceAsString(),
                'Tipo' => 'Excepcion'
            ]);
            throw new HttpException('500', 'Internal Server Error');
        }
        

        return 'OK';
    }
}
