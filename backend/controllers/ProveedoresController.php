<?php

namespace backend\controllers;

use common\models\GestorProveedores;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class ProveedoresController extends Controller
{
    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarProveedores');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorProveedores();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $provs = $gestor->Buscar($busqueda->Cadena, $busqueda->Check);
        } else {
            $provs = $gestor->Buscar();
        }

        $paginado->totalCount = count($provs);
        $provs = array_slice($provs, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $provs,
            'busqueda' => $busqueda
        ]);
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarUsuario');
        
        $usuario = new Usuarios();

        $usuario->setScenario(Usuarios::_MODIFICAR);

        if ($usuario->load(Yii::$app->request->post()) && $usuario->validate()) {
            $gestor = new GestorUsuarios();
            $resultado = $gestor->Modificar($usuario);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $usuario->IdUsuario = $id;
            
            $usuario->Dame();

            return $this->renderAjax('alta', [
                        'titulo' => 'Editar usuario',
                        'model' => $usuario
            ]);
        }
    }
}

?>