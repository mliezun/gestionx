<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\Roles;
use common\models\GestorRoles;
use common\models\forms\BuscarForm;
use common\models\forms\AuditoriaForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class RolesController extends BaseController
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
            'busqueda' => $busqueda,
            'paginado' => $paginado
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

    public function actionClonar($id)
    {
        PermisosHelper::verificarPermiso('ClonarRol');

        $rol = new Roles();
        $rol->setScenario(Roles::SCENARIO_CLONAR);

        //Agrego todo el post al objeto rol, aunque el Id corresponde al rol clonado
        //y el nombre al nuevo y por eso queda feo, es más práctico para poder validar.
        if ($rol->load(Yii::$app->request->post()) && $rol->validate()) {
            $resultado = $rol->Clonar($rol->Rol);

            Yii::$app->response->format = 'json';

            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $rol->IdRol = $id;

            return $this->renderAjax('clonar', [
                        'titulo' => 'Clonar rol',
                        'model' => $rol,
            ]);
        }
    }

    public function actionPermisos($id)
    {
        PermisosHelper::verificarPermiso('ListarPermisosRol');

        $rol = new Roles();
        if (intval($id)) {
            $rol->IdRol = $id;
        } else {
            throw new HttpException('422', 'El rol indicado no es válido.');
        }

        $rol->Dame();

        $permisos = $rol->ListarPermisos();

        $auditoria = new AuditoriaForm();

        if (Yii::$app->request->getIsPost() && $auditoria->load(Yii::$app->request->post()) && $auditoria->validate()) {
            PermisosHelper::verificarPermiso('AsignarPermisosRol');

            $permisosHabilitados = Yii::$app->request->post('Permisos');

            $listapermisos = '';

            if (count($permisosHabilitados) > 0) {
                foreach (array_keys($permisosHabilitados) as $idPermiso) {
                    $listapermisos .= $idPermiso . ',';
                }
                $listapermisos = substr($listapermisos, 0, -1);
            }

            $resultado = $rol->AsignarPermisos($listapermisos, $auditoria->Motivo, $auditoria->Autoriza);

            if ($resultado == 'OK') {
                Yii::$app->session->setFlash('success', 'Permisos modificados correctamente');
            } else {
                Yii::$app->session->setFlash('danger', $resultado);
            }
            return $this->refresh();
        } else {
            return $this->render('permisos', [
                        'model' => $rol,
                        'permisos' => $permisos,
                        'auditoria' => $auditoria,
            ]);
        }
    }
}

?>