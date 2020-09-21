<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\GestorUsuarios;
use common\models\GestorRoles;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use common\models\forms\CambiarPasswordForm;
use common\helpers\PermisosHelper;
use common\components\EmailHelper;
use Yii;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

use common\models\GestorCanales;

class UsuariosController extends BaseController
{
    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarUsuarios');
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorUsuarios();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Combo ? $busqueda->Combo : 'A';
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
            'roles' => $roles,
            'paginado' => $paginado
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

                // Yapada
                // $usuario->Dame();
                // $canales = GestorCanales::Buscar('Por Defecto', 'N', $usuario->IdEmpresa);
                // $idListaPorDefecto = $canales[0]['IdCanal'] ?? 0;
                // Yii::$app->session->set('IDCANALPORDEFECTO', $idListaPorDefecto);

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

            $gestorRoles = new GestorRoles();

            $roles = $gestorRoles->Buscar();

            return $this->renderAjax('alta', [
                        'model' => $usuario,
                        'roles' => $roles
            ]);
        }
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaUsuario');
        
        $usuario = new Usuarios();

        $usuario->setScenario(Usuarios::_ALTA);

        if ($usuario->load(Yii::$app->request->post()) && $usuario->validate()) {
            $usuario->Password = $this->generateRandomString();

            $gestor = new GestorUsuarios();
            $resultado = $gestor->Alta($usuario);

            $parametros = Yii::$app->session->get('Parametros');
            $from = "{$parametros['EMPRESA']} <{$parametros['CORREONOTIFICACIONES']}>";

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                EmailHelper::enviarEmail(
                    $from,
                    $usuario->Email,
                    'Alta usuario ' . $parametros['EMPRESA'],
                    'alta-usuario',
                    [
                    'usuario' => $usuario->Usuario,
                    'password' => $usuario->Password
                ]
                );
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $gestorRoles = new GestorRoles();

            $roles = $gestorRoles->Buscar();

            return $this->renderAjax('alta', [
                        'model' => $usuario,
                        'roles' => $roles
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
        PermisosHelper::verificarPermiso('RestablecerPassword');

        Yii::$app->response->format = 'json';

        $usuario = new Usuarios();

        $usuario->IdUsuario = $id;

        $usuario->Dame();

        $pass = $this->generateRandomString();

        $parametros = Yii::$app->session->get('Parametros');
        $from = "{$parametros['EMPRESA']} <{$parametros['CORREONOTIFICACIONES']}>";

        $resultado = $usuario->RestablecerPassword($pass);

        if ($resultado != 'OK') {
            return ['error' => $resultado];
        }
        
        EmailHelper::enviarEmail(
            $from,
            $usuario->Email,
            'Restablecimiento de contraseña ' . $parametros['EMPRESA'],
            'restablecer-pass',
            [
            'password' => $pass
        ]
        );
            
        return ['error' => null];
    }

    public function actionSesiones($id)
    {
        PermisosHelper::verificarPermiso('BuscarUsuarios');

        $usuario = new Usuarios;

        $usuario->IdUsuario = $id;

        $usuario->Dame();

        $sesiones = $usuario->ListarSesiones();

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $paginado->totalCount = count($sesiones);
        $sesiones = array_slice($sesiones, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('sesiones', [
            'model' => $usuario,
            'models' => $sesiones,
            'paginado' => $paginado
        ]);
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarUsuario');

        Yii::$app->response->format = 'json';
        
        $usuario = new Usuarios();
        $usuario->IdUsuario = $id;

        $resultado = $usuario->Activar();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaUsuario');

        Yii::$app->response->format = 'json';
        
        $usuario = new Usuarios();
        $usuario->IdUsuario = $id;

        $resultado = $usuario->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
