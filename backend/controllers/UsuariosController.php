<?php

namespace backend\controllers;

use yii\web\Controller;
use common\models\Usuarios;
use common\models\Empresa;
use Yii;
use yii\helpers\ArrayHelper;
use common\components\PermisosHelper;

class UsuariosController extends Controller
{       
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
        Yii::$app->user->logout();
        return $this->goHome();
    }

    /*
    
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

    */
}

?>