<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\GestorUsuarios;
use common\models\GestorRoles;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use common\models\forms\CambiarPasswordForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class UsuariosController extends Controller
{
    public function actionIndex()
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorUsuarios();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Combo != 0 ? $busqueda->Combo : 'A';
            $usuarios = $gestor->Buscar($busqueda->Cadena, $estado, $busqueda->Combo2);
        } else {
            $usuarios = $gestor->Buscar();
        }

        $paginado->totalCount = count($usuarios);
        $usuarios = array_slice($usuarios, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        $gestorRoles = new GestorRoles();

        $roles = $gestorRoles->Buscar();

        return $this->render('index', [
            'models' => $usuarios,
            'busqueda' => $busqueda,
            'roles' => $roles
        ]);
    }

    public function actionLogin()
    {
        // Si ya estoy logueado redirecciona al home
        if (!Yii::$app->user->isGuest) {
            return $this->goHome();
        }

        // Guardo también en la sesión los parámetros de Empresa
        $empresa = new Empresa();
        Yii::$app->session->open();

        $usuario = new Usuarios();
        $usuario->setScenario(Usuarios::_LOGIN);

        $this->layout = 'login';

        if ($usuario->load(Yii::$app->request->post()) && $usuario->validate()) {
            $login = $usuario->Login('A', $usuario->Password, Yii::$app->security->generateRandomString(300));

            if ($login['Mensaje'] == 'OK') {
                Yii::$app->user->login($usuario);
                Yii::$app->session->set('Token', $usuario->Token);
                Yii::$app->session->set('Parametros', ArrayHelper::map($empresa->DameDatos(), 'Parametro', 'Valor'));

                PermisosHelper::guardarPermisosSesion($usuario->DamePermisos());

                // El usuario debe modificar el password
                if ($usuario->DebeCambiarPass == 'S') {
                    Yii::$app->session->setFlash('info', 'Debe modificar su contraseña antes de ingresar.');
                    return $this->redirect('/usuarios/cambiar-password');
                } else {
                    return $this->redirect(Yii::$app->user->returnUrl);
                }
            } else {
                $usuario->Password = null;
                Yii::$app->session->setFlash('danger', $login['Mensaje']);
            }
        }
        Yii::$app->session->set('Parametros', ArrayHelper::map($empresa->DameDatos(), 'Parametro', 'Valor'));

        return $this->render('login', [
            'model' => $usuario,
        ]);
    }
    
    public function actionLogout()
    {
        Yii::$app->user->identity->Logout();
        Yii::$app->user->logout();
        return $this->goHome();
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
    
    public function actionCambiarPassword()
    {
        $form = new CambiarPasswordForm();

        $this->layout = 'login';

        if ($form->load(Yii::$app->request->post()) && $form->validate()) {
            $usuario = Yii::$app->user->identity;

            $mensaje = $usuario->CambiarPassword($usuario->Token, $form->Anterior, $form->Password_repeat);

            if ($mensaje == 'OK') {
                Yii::$app->user->logout();
                Yii::$app->session->setFlash('success', 'La contraseña fue modificada.');
                return $this->goHome();
            } else {
                Yii::$app->session->setFlash('danger', $mensaje);
                return $this->render('password', [
                            'model' => $form,
                ]);
            }
        } else {
            return $this->render('password', [
                        'model' => $form,
            ]);
        }
    }

    private function generateRandomString($length = 10)
    {
        $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $charactersLength = strlen($characters);
        $randomString = '';
        for ($i = 0; $i < $length; $i++) {
            $randomString .= $characters[rand(0, $charactersLength - 1)];
        }
        return $randomString;
    }

    public function actionRestablecerPass($id)
    {
        if (!PermisosHelper::tienePermiso('RestablecerPassword')) {
            PermisosHelper::tirarExcepcion();
        }

        Yii::$app->response->format = 'json';

        $usuario = new Usuarios();

        $usuario->IdUsuario = $id;

        $pass = $this->generateRandomString();

        Yii::info($pass);

        $resultado = $usuario->RestablecerPassword($pass);

        if ($resultado == 'OK') {
            return ['error' => null];
        }

        return ['error' => $resultado];
    }
}

?>