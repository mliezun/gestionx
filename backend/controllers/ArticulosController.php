<?php

namespace backend\controllers;

use common\models\GestorArticulos;
use common\models\Articulos;
use common\models\GestorProveedores;
use common\models\GestorTiposIVA;
use common\models\GestorListasPrecio;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use common\components\NinjaArrayHelper;
use Yii;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class ArticulosController extends BaseController
{
    public function actionListar($id, $Cadena)
    {
        Yii::$app->response->format = 'json';

        $gestor = new GestorArticulos();

        return $gestor->BuscarPorCliente($id, $Cadena);
    }

    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarArticulos');

        $gestor = new GestorArticulos();

        $paginado = new Pagination(['totalCount' => $gestor->DameCantidad()]);
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        if ($busqueda->load(Yii::$app->request->get()) && $busqueda->validate()) {
            $articulos = $gestor->Buscar($paginado->offset, $paginado->limit, $busqueda->Cadena, $busqueda->Combo, $busqueda->Combo2, $busqueda->Check);
        } else {
            $articulos = $gestor->Buscar($paginado->offset, $paginado->limit);
        }

        $gestorProv = new GestorProveedores();
        $proveedores = $gestorProv->Buscar();

        $listas = GestorListasPrecio::Buscar();

        return $this->render('index', [
            'models' => $articulos,
            'busqueda' => $busqueda,
            'proveedores' => $proveedores,
            'listas' => $listas,
            'paginado' => $paginado
        ]);
    }

    public function actionAutocompletar($q = null, $id = null)
    {
        Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;

        $out = ['results' => ['id' => '', 'text' => '']];

        if (!is_null($q)) {
            $gestor = new GestorArticulos();
            $articulos = $gestor->BuscarAutocompletado($q);
            $articulos = NinjaArrayHelper::renameKeys($articulos, [
                'IdArticulo' => 'id',
                'Articulo' => 'text'
            ]);
            $out['results'] = $articulos;
        } elseif ($id > 0) {
            $articulo = new Articulos();
            $articulo->IdArticulo = $id;
            $articulo->Dame();
            $out['results'] = ['id' => $id, 'text' => $articulo->Articulo];
        }

        return $out;
    }

    public function actionAlta()
    {
        // PermisosHelper::verificarPermiso('AltaArticulo');

        // $art = new Articulos();
        // $art->setScenario(Articulos::SCENARIO_ALTA);

        // Yii::info(Yii::$app->request->post());

        // $gestor = new GestorArticulos();

        // return parent::alta($art, [$gestor, 'Alta'], function () use ($art) {
        //     $art->IdEmpresa = Yii::$app->user->identity->IdEmpresa;
        // });
        PermisosHelper::verificarPermiso('AltaArticulo');

        $articulo = new Articulos();
        $articulo->setScenario(Articulos::SCENARIO_ALTA);

        if ($articulo->load(Yii::$app->request->post()) && $articulo->validate()) {
            $resultado = (new GestorArticulos())->Alta($articulo);
            
            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $proveedores = GestorProveedores::Buscar();
            $listas = GestorListasPrecio::Buscar();
            $ivas = GestorTiposIVA::Buscar();

            // 21% por defecto
            $articulo->IdTipoIVA = 5;

            return $this->renderAjax('alta', [
                'titulo' => 'Alta Articulo',
                'model' => $articulo,
                'listas' => $listas,
                'proveedores' => $proveedores,
                'ivas' => $ivas
            ]);
        }
    }

    public function actionEditar($id)
    {
        // PermisosHelper::verificarPermiso('ModificarArticulo');
        
        // $art = new Articulos();
        // $art->setScenario(Articulos::SCENARIO_EDITAR);

        // $gestor = new GestorArticulos();

        // return parent::alta($art, array($gestor, 'Modificar'), function () use ($art, $id) {
        //     $art->IdArticulo = $id;
        //     $art->Dame();
        // });

        PermisosHelper::verificarPermiso('ModificarArticulo');

        $articulo = new Articulos();
        $articulo->setScenario(Articulos::SCENARIO_EDITAR);

        if ($articulo->load(Yii::$app->request->post()) && $articulo->validate()) {
            $resultado = (new GestorArticulos())->Modificar($articulo);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $articulo->IdArticulo = $id;
            $articulo->Dame();

            $proveedores = GestorProveedores::Buscar();
            $listas = GestorListasPrecio::Buscar();
            $ivas = GestorTiposIVA::Buscar();

            return $this->renderAjax('alta', [
                'titulo' => 'Modificar Pago',
                'model' => $articulo,
                'listas' => $listas,
                'proveedores' => $proveedores,
                'ivas' => $ivas
            ]);
        }
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

    public function actionHistorial($id)
    {
        PermisosHelper::verificarPermiso('ListarHistorialPreciosArticulo');

        $articulo = new Articulos();
        $articulo->IdArticulo = $id;
        $articulo->Dame();

        $historicos = $articulo->ListarHistorialPrecios();

        return $this->renderAjax('historial', [
            'models' => $historicos,
            'articulo' => $articulo
        ]);
    }
}
