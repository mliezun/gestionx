<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\Roles;
use common\models\GestorRoles;
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

        $gestor = new GestorRoles();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Combo ? $busqueda->Combo : 'A';
            $roles = $gestor->Buscar($busqueda->Cadena, $estado);
        } else {
            $roles = $gestor->Buscar();
        }

        $paginado->totalCount = count($roles);
        $roles = array_slice($roles, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $roles,
            'busqueda' => $busqueda
        ]);
    }
}

?>