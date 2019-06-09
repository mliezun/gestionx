<?php

namespace backend\controllers;

use common\models\GestorArticulos;
use common\models\GestorProveedores;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class ArticulosController extends Controller
{
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
}

?>