<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\ListasPrecio;
use common\models\GestorListasPrecio;
use common\models\forms\BuscarForm;
use common\models\forms\AuditoriaForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class ListasPrecioController extends BaseController
{
    public function actionIndex()
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Check ? $busqueda->Check : 'N';
            $listas = GestorListasPrecio::Buscar('S',$busqueda->Cadena, $estado);
        } else {
            $listas = GestorListasPrecio::Buscar('S');
        }

        $paginado->totalCount = count($listas);
        $listas = array_slice($listas, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $listas,
            'busqueda' => $busqueda,
            'paginado' => $paginado
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaListaPrecio');

        $lista = new ListasPrecio();

        $lista->setScenario(ListasPrecio::_ALTA);

        if($lista->load(Yii::$app->request->post()) && $lista->validate()){
            $gestor = new GestorListasPrecio();
            $resultado = $gestor->Alta($lista);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        }else {
            return $this->renderAjax('alta', [
                'titulo' => 'Alta Lista de Precios',
                'model' => $lista
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarListaPrecio');
        
        $lista = new ListasPrecio();

        $lista->setScenario(ListasPrecio::_MODIFICAR);

        if ($lista->load(Yii::$app->request->post())) {
            $gestor = new GestorListasPrecio();
            $resultado = $gestor->Modificar($lista);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $lista->IdListaPrecio = $id;
            
            $lista->Dame();

            return $this->renderAjax('alta', [
                        'titulo' => 'Editar Lista de Precios',
                        'model' => $lista
            ]);
        }
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarListaPrecio');

        Yii::$app->response->format = 'json';
        
        $lista = new ListasPrecio();
        $lista->IdListaPrecio = $id;

        $gestor = new GestorListasPrecio();

        $resultado = $gestor->Borrar($lista);

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
        
        $lista = new ListasPrecio();
        $lista->IdListaPrecio = $id;

        $resultado = $lista->Activa();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}

?>