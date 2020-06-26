<?php

namespace backend\controllers;

use common\models\Remitos;
use common\models\PuntosVenta;
use common\models\GestorRemitos;
use common\models\GestorProveedores;
use common\models\GestorCanales;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class RemitosController extends BaseController
{
    public function actionAlta($id)
    {
        PermisosHelper::verificarPermiso('AltaRemito');

        $remito = new Remitos();

        $remito->setScenario(Remitos::_ALTA);

        if ($remito->load(Yii::$app->request->post())) {
            $gestor = new GestorRemitos();
            $remito->IdEmpresa = Yii::$app->user->identity->IdEmpresa;
            $remito->IdCanal = $remito->IdCanal ?? Yii::$app->session->get('Parametros')['CANALPORDEFECTO'];

            $resultado = $gestor->Alta($remito, $id);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $proveedores = (new GestorProveedores())->Buscar();

            $canales = GestorCanales::Buscar();

            return $this->renderAjax('alta', [
                'titulo' => 'Alta remito',
                'model' => $remito,
                'canales' => $canales,
                'proveedores' => $proveedores
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarRemito');
        
        $remito = new Remitos();

        $remito->setScenario(Remitos::_MODIFICAR);

        if ($remito->load(Yii::$app->request->post()) && $remito->validate()) {
            $gestor = new GestorRemitos();
            $resultado = $gestor->Modificar($remito);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $remito->IdRemito = $id;
            $remito->Dame();

            $proveedores = (new GestorProveedores())->Buscar();

            $canales = GestorCanales::Buscar();

            return $this->renderAjax('alta', [
                'titulo' => 'Editar Remito',
                'model' => $remito,
                'canales' => $canales,
                'proveedores' => $proveedores
            ]);
        }
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarRemito');

        Yii::$app->response->format = 'json';
        
        $remito = new Remitos();
        $remito->IdRemito = $id;

        $resultado = $remito->Activar();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaRemito');

        Yii::$app->response->format = 'json';
        
        $remito = new Remitos();
        $remito->IdRemito = $id;

        $resultado = $remito->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
