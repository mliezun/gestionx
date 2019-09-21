<?php

namespace backend\controllers;

use common\models\RectificacionesPV;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class RectificacionesPVController extends BaseController
{
    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaRectificacionesPV');

        $rectificacionesPV = new RectificacionesPV();

        $rectificacionesPV->setScenario(RectificacionesPV::_ALTA);

        if ($rectificacionesPV->load(Yii::$app->request->post()) && $rectificacionesPV->validate()) {
            $gestor = new GestorPuntosVenta();
            $resultado = $gestor->Alta($rectificacionesPV);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            return $this->renderAjax('alta', [
                'titulo' => 'Alta punto de venta',
                'model' => $rectificacionesPV
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarPuntoVenta');
        
        $puntoventa = new PuntosVenta();

        $puntoventa->setScenario(PuntosVenta::_MODIFICAR);

        if ($puntoventa->load(Yii::$app->request->post()) && $puntoventa->validate()) {
            $gestor = new GestorPuntosVenta();
            $resultado = $gestor->Modificar($puntoventa);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $puntoventa->IdPuntoVenta = $id;
            
            $puntoventa->Dame();

            return $this->renderAjax('alta', [
                        'titulo' => 'Editar punto de venta',
                        'model' => $puntoventa
            ]);
        }
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarPuntoVenta');

        Yii::$app->response->format = 'json';
        
        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $id;

        $gestor = new GestorPuntosVenta();

        $resultado = $gestor->Borrar($puntoventa);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarPuntoVenta');

        Yii::$app->response->format = 'json';
        
        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $id;

        $resultado = $puntoventa->Activa();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaPuntoVenta');

        Yii::$app->response->format = 'json';
        
        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $id;

        $resultado = $puntoventa->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
