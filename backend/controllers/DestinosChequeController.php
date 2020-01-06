<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\DestinosCheque;
use common\models\GestorDestinosCheque;
use common\models\forms\BuscarForm;
use common\models\forms\AuditoriaForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class DestinosChequeController extends BaseController
{
    public function actionIndex()
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Combo ? $busqueda->Combo : 'A';
            $destinos = GestorDestinosCheque::Buscar($busqueda->Cadena, $estado);
        } else {
            $destinos = GestorDestinosCheque::Buscar();
        }

        $paginado->totalCount = count($destinos);
        $destinos = array_slice($destinos, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $destinos,
            'busqueda' => $busqueda,
            'paginado' => $paginado
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaListaPrecio');

        $destino = new DestinosCheque();

        $destino->setScenario(DestinosCheque::SCENARIO_ALTA);

        if($destino->load(Yii::$app->request->post()) && $destino->validate()){
            $resultado = GestorDestinosCheque::Alta($destino);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        }else {
            return $this->renderAjax('alta', [
                'titulo' => 'Alta Destino de Cheque',
                'model' => $destino
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarListaPrecio');
        
        $destino = new DestinosCheque();

        $destino->setScenario(DestinosCheque::SCENARIO_MODIFICAR);

        if ($destino->load(Yii::$app->request->post()) && $destino->validate() ) {
            $resultado = GestorDestinosCheque::Modificar($destino);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $destino->IdDestinoCheque = $id;
            
            $destino->Dame();

            return $this->renderAjax('alta', [
                'titulo' => 'Editar Destino de Cheque',
                'model' => $destino
            ]);
        }
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarListaPrecio');

        Yii::$app->response->format = 'json';
        
        $destino = new DestinosCheque();
        $destino->IdDestinoCheque = $id;

        $resultado = GestorDestinosCheque::Borrar($destino);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarListaPrecio');

        Yii::$app->response->format = 'json';
        
        $destino = new DestinosCheque();
        $destino->IdDestinoCheque = $id;

        $resultado = $destino->Activa();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('ActivarListaPrecio');

        Yii::$app->response->format = 'json';
        
        $destino = new DestinosCheque();
        $destino->IdDestinoCheque = $id;

        $resultado = $destino->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}

?>