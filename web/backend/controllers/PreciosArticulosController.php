<?php

namespace backend\controllers;

use common\models\Articulos;
use common\models\ListasPrecio;
use common\models\PreciosArticulos;
use common\models\GestorArticulos;
use common\models\GestorListasPrecio;
use common\models\forms\BuscarForm;
use common\models\forms\LineasForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;
use yii\helpers\Url;

class PreciosArticulosController extends BaseController
{
    public function actionIndex($id)
    {
        PermisosHelper::verificarPermiso('ModificarArticulo');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $articulo = new Articulos();
        $articulo->IdArticulo = $id;
        $articulo->Dame();

        $precios = $articulo->DameListasPrecios();

        $anterior = [
            'label' => "Articulos",
            'link' => Url::to(['/articulos'])
        ];
        $titulo = 'Precios del Articulo ' . $articulo->Articulo;

        $paginado->totalCount = count($precios);
        $precios = array_slice($precios, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'model' => $articulo,
            'precios' => $precios,
            'anterior' => $anterior,
            'titulo' => $titulo,
            'busqueda' => $busqueda,
            'paginado' => $paginado
        ]);
    }
    
    public function actionAlta($id)
    {
        PermisosHelper::verificarPermiso('ModificarArticulo');

        $articulo = new Articulos();
        $articulo->IdArticulo = $id;

        $precio = new PreciosArticulos();

        $listas = GestorListasPrecio::Buscar();

        if ($precio->load(Yii::$app->request->post()) && $precio->validate()) {
            $resultado = $articulo->AgregarPrecio($precio);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            return $this->renderAjax('alta', [
                'titulo' => 'Agregar Precio',
                'model' => $precio,
                'listas' => $listas
            ]);
        }
    }

    public function actionEditar($idArt, $idLis)
    {
        PermisosHelper::verificarPermiso('ModificarArticulo');

        $precio = new PreciosArticulos();
        $precio->IdArticulo = $idArt;
        $precio->IdListaPrecio = $idLis;
        $precio->Dame();

        $articulo = new Articulos();
        $articulo->IdArticulo = $idArt;

        $listas=0;

        if ($precio->load(Yii::$app->request->post()) && $precio->validate()) {
            $resultado = $articulo->ModificarPrecio($precio);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            return $this->renderAjax('alta', [
                'titulo' => 'Modificar Pago',
                'model' => $precio,
                'listas' => $listas
            ]);
        }
    }

    public function actionBorrar($idArt, $idLis)
    {
        PermisosHelper::verificarPermiso('TODO:ModificarArticulo');

        Yii::$app->response->format = 'json';
        
        $precio = new PreciosArticulos();
        $precio->IdArticulo = $idArt;
        $precio->IdListaPrecio = $idLis;
        $precio->Dame();

        $articulo = new Articulos();
        $articulo->IdArticulo = $idArt;

        $resultado = $articulo->BorrarPrecio($precio);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
