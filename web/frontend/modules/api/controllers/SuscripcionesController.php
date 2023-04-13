<?php

namespace frontend\modules\api\controllers;

use yii\helpers\ArrayHelper;
use yii\web\HttpException;
use common\models\GestorSuscripciones;
use common\models\Suscripciones;
use common\models\Planes;
use common\models\EstrategiaSuscripciones;
use frontend\modules\api\filters\auth\OptionalBearerAuth;
use Yii;

class SuscripcionesController extends BaseController
{
    public function behaviors()
    {
        return ArrayHelper::merge(
            parent::behaviors(),
            [
                    'bearerAuth' => [
                        'class' => OptionalBearerAuth::className()
                    ],
            ]
        );
    }

    /**
     * @api {post} /suscripciones Alta Suscripción
     * @apiName AltaSuscripcion
     * @apiGroup Suscripciones
     * @apiPermission logueado
     * 
     * @apiParam {Number} IdPlan Identificador del Plan a Suscribirse
     * @apiParam {String} Codigo Código de bonificación
     * @apiParam {String} Tipo Proveedor del pago [Paypal]
     *
     * @apiSuccess {String} URL Link para redirigir al cliente.
     * @apiError {String} Error Mensaje de error.
     */
    public function actionCreate()
    {
        $Tipo = Yii::$app->request->post('Tipo');
        $IdPlan = Yii::$app->request->post('IdPlan');
        $Codigo = Yii::$app->request->post('Codigo');
        $estrategia = new EstrategiaSuscripciones($Tipo);
        return $estrategia->Alta($IdPlan, $Codigo);
    }
    
    /**
     * @api {get} /suscripciones Listar Historial suscripciones
     * @apiName ListaSuscripciones
     * @apiGroup Suscripciones
     * @apiPermission logueado
     *
     * @apiSuccess {Int} Suscripciones.IdSuscripcion Identificador de la Suscripcion
     * @apiSuccess {Int} Suscripciones.IdPlan Identificador del Plan
     * @apiSuccess {Date} Suscripciones.FechaInicio Fecha de inicio de la suscripcion
     * @apiSuccess {Date} Suscripciones.FechaFin Fecha de finalizacion de la suscripcion
     * @apiSuccess {Date} Suscripciones.FechaBaja Fecha de la Baja de la suscripcion
     * @apiSuccess {String} Suscripciones.AgenteBaja Indica si la baja la realizo el Usuario o el proceso automatico al llegar al vencimiento.
     * @apiSuccess {String} Suscripciones.Renovar Indica si la suscripcion debe renovarse automaticamente al finalizar el período.
     * @apiSuccess {String} Suscripciones.Estado Indica el estado de la suscripcion [A: Alta | B: Baja].
     * @apiSuccess {String} Suscripciones.Bonificado Indica si la suscripcion tuvo una bonificacion (S/N).
     * @apiSuccess {String} Suscripciones.CodigoBonifUsado Codigo de bonificacion utilizado.
     * @apiError {String} Error Mensaje de error.
     */
    public function actionIndex()
    {
        $gestor = new GestorSuscripciones();

        $listado = $gestor->HistorialSuscripcionesUsuario();

        $out = [];
        foreach ($listado as $u) {
            $out[] = [
                'IdSuscripcion' => $u['IdSuscripcion'],
                'IdPlan' => $u['IdPlan'],
                'IdUsuario' => $u['IdUsuario'],
                'FechaInicio' => $u['FechaInicio'],
                'FechaFin' => $u['FechaFin'],
                'FechaBaja' => $u['FechaBaja'],
                'AgenteBaja' => $u['AgenteBaja'],
                'Renovar' => $u['Renovar'],
                'Estado' => $u['Estado'],
                'Bonificado' => $u['Bonificado'],
                'CodigoBonifUsado' => $u['CodigoBonifUsado'],
            ];
        }
        return $out;
    }

    /**
     * @api {post} /suscripciones/cancelar Cancelar Suscripción
     * @apiName CancelarSuscripcion
     * @apiGroup Suscripciones
     * @apiPermission logueado
     * 
     * @apiParam {Number} IdSuscripcion Identificador de la suscripción
     *
     * @apiError {String} Error Mensaje de error.
     */
    public function actionCancelar()
    {
        $IdSuscripcion = Yii::$app->request->post('IdSuscripcion');

        $suscripcion = new Suscripciones;

        $suscripcion->IdSuscripcion = $IdSuscripcion;

        $suscripcion->Dame();

        if ($suscripcion->Estado != 'A' && $suscripcion->Estado != 'F') {
            return ['Error' => 'SUSCRNOTFOUND'];
        }

        $suscripcion->Datos = json_decode($suscripcion->Datos, true);

        $estrategia = new EstrategiaSuscripciones($suscripcion->Datos['Proveedor']);
        return $estrategia->Cancelar($suscripcion);
    }
}
