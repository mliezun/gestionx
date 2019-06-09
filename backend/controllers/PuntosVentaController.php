<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\PuntosVenta;
use common\models\GestorPuntosVenta;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class PuntosVentaController extends Controller
{
    public function actionIndex()
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorPuntosVenta();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Combo ? $busqueda->Combo : 'A';
            $puntosventa = $gestor->Buscar($busqueda->Cadena, $estado);
        } else {
            $puntosventa = $gestor->Buscar();
        }
        
        $paginado->totalCount = count($puntosventa);
        $puntosventa = array_slice($puntosventa, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $puntosventa,
            'busqueda' => $busqueda
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaPuntoVenta');

        $puntoventa = new PuntosVenta();

        $puntoventa->setScenario(PuntosVenta::_ALTA);

        if($puntoventa->load(Yii::$app->request->post()) && $puntoventa->validate()){
            $gestor = new GestorPuntosVenta();
            $resultado = $gestor->Alta($puntoventa);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        }else {
            return $this->renderAjax('alta', [
                'titulo' => 'Alta punto de venta',
                'model' => $puntoventa
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

?>