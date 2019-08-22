<?php

namespace backend\controllers;

use common\models\GestorArticulos;
use common\models\Articulos;
use common\models\GestorProveedores;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class ArticulosController extends BaseController
{

    public function actionListar($id,$Cadena)
    {
        Yii::$app->response->format = 'json';

        $gestor = new GestorArticulos();

        return $gestor->BuscarPorCliente($id,$Cadena);
    }

    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarArticulos');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorArticulos();

        if ($busqueda->load(Yii::$app->request->get()) && $busqueda->validate()) {
            $articulos = $gestor->Buscar($busqueda->Combo, $busqueda->Cadena, $busqueda->Check);
        } else {
            $articulos = $gestor->Buscar();
        }

        $paginado->totalCount = count($articulos);
        $articulos = array_slice($articulos, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        $gestorProv = new GestorProveedores();
        $proveedores = $gestorProv->Buscar();

        return $this->render('index', [
            'models' => $articulos,
            'busqueda' => $busqueda,
            'proveedores' => $proveedores
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaArticulo');

        $art = new Articulos();
        $art->setScenario(Articulos::SCENARIO_ALTA);

        Yii::info(Yii::$app->request->post());

        $gestor = new GestorArticulos();

        return parent::alta($art, [$gestor, 'Alta'], function () use ($art) {
            $art->IdEmpresa = Yii::$app->user->identity->IdEmpresa;
        });
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarArticulo');
        
        $art = new Articulos();
        $art->setScenario(Articulos::SCENARIO_EDITAR);

        $gestor = new GestorArticulos();

        return parent::alta($art, array($gestor, 'Modificar'), function () use ($art, $id) {
            $art->IdArticulo = $id;
            $art->Dame();
        });
    }

    public function actionEditarListas($id)
    {
        PermisosHelper::verificarPermiso('ModificarArticulo');
        
        $art = new Articulos();
        $art->setScenario(Articulos::SCENARIO_EDITAR);

        $art->IdArticulo = $id;
        $art->Dame();

        if ($art->load(Yii::$app->request->post()) && $art->validate()) {
            $gestor = new GestorArticulos();
            $resultado = $gestor->Modificar($art);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            return $this->renderAjax('alta', [
                        'titulo' => 'Editar Listas',
                        'model' => $art
            ]);
        }
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarArticulo');

        $art = new Articulos();
        $art->IdArticulo = $id;

        return parent::cambiarEstado($art, 'Activar');
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaArticulo');

        $art = new Articulos();
        $art->IdArticulo = $id;

        return parent::cambiarEstado($art, 'DarBaja');
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarArticulo');

        $art = new Articulos();
        $art->IdArticulo = $id;

        return parent::aplicarOperacionGestor($art, array(new GestorArticulos, 'Borrar'));
    }
}

?>