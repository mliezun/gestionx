<?php

namespace backend\controllers;

use common\models\Canales;
use common\models\GestorCanales;
use common\models\forms\BuscarForm;
use common\models\forms\AuditoriaForm;
use common\helpers\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;
use yii\web\HttpException;

class CanalesController extends BaseController
{
    public function actionIndex()
    {
        if (Yii::$app->session->get('Parametros')['CANTCANALES'] == 1) {
            throw new HttpException('403', 'No se tienen los permisos necesarios para ver la página solicitada.');
        }

        PermisosHelper::verificarPermiso('BuscarCanales');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $incluye = $busqueda->Check ? $busqueda->Check : 'N';
            $cadena = $busqueda->Cadena ? $busqueda->Cadena : '';
            $canales = GestorCanales::Buscar($cadena, $incluye);
        } else {
            $canales = GestorCanales::Buscar();
        }

        $paginado->totalCount = count($canales);
        $canales = array_slice($canales, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $canales,
            'busqueda' => $busqueda,
            'paginado' => $paginado
        ]);
    }

    public function actionAlta()
    {
        if (Yii::$app->session->get('Parametros')['CANTCANALES'] == 1) {
            throw new HttpException('403', 'No se tienen los permisos necesarios para ver la página solicitada.');
        }

        PermisosHelper::verificarPermiso('AltaCanal');

        $canal = new Canales();

        $canal->setScenario(Canales::_ALTA);

        if ($canal->load(Yii::$app->request->post()) && $canal->validate()) {
            $resultado = GestorCanales::Alta($canal);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            return $this->renderAjax('alta', [
                'titulo' => 'Alta Canal',
                'model' => $canal
            ]);
        }
    }

    public function actionEditar($id)
    {
        if (Yii::$app->session->get('Parametros')['CANTCANALES'] == 1) {
            throw new HttpException('403', 'No se tienen los permisos necesarios para ver la página solicitada.');
        }

        PermisosHelper::verificarPermiso('ModificarCanal');
        
        $canal = new Canales();

        $canal->setScenario(Canales::_MODIFICAR);

        if ($canal->load(Yii::$app->request->post()) && $canal->validate()) {
            $resultado = GestorCanales::Modificar($canal);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $canal->IdCanal = $id;
            
            $canal->Dame();

            return $this->renderAjax('alta', [
                'titulo' => 'Editar Canal',
                'model' => $canal
            ]);
        }
    }

    public function actionBorrar($id)
    {
        if (Yii::$app->session->get('Parametros')['CANTCANALES'] == 1) {
            throw new HttpException('403', 'No se tienen los permisos necesarios para ver la página solicitada.');
        }

        PermisosHelper::verificarPermiso('BorrarCanal');

        Yii::$app->response->format = 'json';
        
        $canal = new Canales();
        $canal->IdCanal = $id;

        $resultado = GestorCanales::Borrar($canal);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionActivar($id)
    {
        if (Yii::$app->session->get('Parametros')['CANTCANALES'] == 1) {
            throw new HttpException('403', 'No se tienen los permisos necesarios para ver la página solicitada.');
        }

        PermisosHelper::verificarPermiso('ActivarCanal');

        Yii::$app->response->format = 'json';
        
        $canal = new Canales();
        $canal->IdCanal = $id;

        $resultado = $canal->Activa();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        if (Yii::$app->session->get('Parametros')['CANTCANALES'] == 1) {
            throw new HttpException('403', 'No se tienen los permisos necesarios para ver la página solicitada.');
        }
        
        PermisosHelper::verificarPermiso('DarBajaCanal');

        Yii::$app->response->format = 'json';
        
        $canal = new Canales();
        $canal->IdCanal = $id;

        $resultado = $canal->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
