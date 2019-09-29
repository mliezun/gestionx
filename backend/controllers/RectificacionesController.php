<?php

namespace backend\controllers;

use common\models\RectificacionesPV;
use common\models\PuntosVenta;
use common\models\GestorPuntosVenta;
use common\models\GestorArticulos;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class RectificacionesController extends BaseController
{
    public function actionAlta($id)
    {
        PermisosHelper::verificarPermiso('AltaRectificacion');

        $rectificacionesPV = new RectificacionesPV();
        $rectificacionesPV->setScenario(RectificacionesPV::_ALTA);

        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $id;

        if ($rectificacionesPV->load(Yii::$app->request->post()) && $rectificacionesPV->validate()) {

            $resultado = $puntoventa->AltaRectificacion($rectificacionesPV);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $articulos = GestorArticulos::Buscar();
            $puntosventa = GestorPuntosVenta::Buscar();
            $clave = array_search($id, $puntosventa);
            unset($puntosventa[$clave]);

            return $this->renderAjax('alta', [
                'titulo' => 'Alta rectificación',
                'model' => $rectificacionesPV,
                'articulos' => $articulos,
                'puntosventa' => $puntosventa
            ]);
        }
    }

    public function actionBorrar($idPv, $idRec)
    {
        PermisosHelper::verificarPermiso('BorrarRectificacion');

        Yii::$app->response->format = 'json';
        
        $rectificacion = new RectificacionesPV();
        $rectificacion->IdRectificacionPV = $idRec;

        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $idPv;

        $resultado = $puntoventa->BorrarRectificacion($rectificacion);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDevolver($idPv, $idRec)
    {
        PermisosHelper::verificarPermiso('DevolucionRectificacion');

        Yii::$app->response->format = 'json';
        
        $rectificacion = new RectificacionesPV();
        $rectificacion->IdRectificacionPV = $idRec;

        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $idPv;

        $resultado = $puntoventa->DevolverRectificacion($rectificacion);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionConfirmar($id)
    {
        PermisosHelper::verificarPermiso('ConfirmarRectificacion');

        Yii::$app->response->format = 'json';
        
        $rectificacion = new RectificacionesPV();
        $rectificacion->IdRectificacionPV = $id;

        $resultado = $rectificacion->Confirma();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
