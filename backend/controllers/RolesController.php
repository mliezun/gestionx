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

class RolesController extends Controller
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

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaRol');

        $rol = new Roles();

        $rol->setScenario(Roles::_ALTA);

        if($rol->load(Yii::$app->request->post()) && $rol->validate()){
            $gestor = new GestorRoles();
            $resultado = $gestor->Alta($rol);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        }else {
            return $this->renderAjax('alta', [
                'titulo' => 'Alta rol',
                'model' => $rol
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarRol');
        
        $rol = new Roles();

        $rol->setScenario(Roles::_MODIFICAR);

        if ($rol->load(Yii::$app->request->post()) && $rol->validate()) {
            $gestor = new GestorRoles();
            $resultado = $gestor->Modificar($rol);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $rol->IdRol = $id;
            
            $rol->Dame();

            return $this->renderAjax('alta', [
                        'titulo' => 'Editar rol',
                        'model' => $rol
            ]);
        }
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarRol');

        Yii::$app->response->format = 'json';
        
        $rol = new Roles();
        $rol->IdRol = $id;

        $gestor = new GestorRoles();

        $resultado = $gestor->Borrar($rol);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarRol');

        Yii::$app->response->format = 'json';
        
        $rol = new Roles();
        $rol->IdRol = $id;

        $resultado = $rol->Activa();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaRol');

        Yii::$app->response->format = 'json';
        
        $rol = new Roles();
        $rol->IdRol = $id;

        $resultado = $rol->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}

?>