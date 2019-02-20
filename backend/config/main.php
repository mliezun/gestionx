<?php
$params = array_merge(
    require __DIR__ . '/../../common/config/params.php',
    require __DIR__ . '/../../common/config/params-local.php',
    require __DIR__ . '/params.php',
    require __DIR__ . '/params-local.php'
);

$config = [
    'id' => 'gestionx-backend',
    'name' => 'GestionX Backend',
    'language' => 'es',
    'basePath' => dirname(__DIR__),
    'controllerNamespace' => 'backend\controllers',
    'bootstrap' => ['log'],
    'components' => [
        'request' => [
            'csrfParam' => 'back_csrf',
            'class' => 'yii\web\Request',
            'parsers' => [
                'application/json' => 'yii\web\JsonParser',
            ],
        ],
        'user' => [
            'identityClass' => 'common\models\Usuarios',
            'loginUrl' => '/usuarios/login',
            'authTimeout' => 60 * 60,
        ],
        'errorHandler' => [
            'errorAction' => 'site/error',
        ],
        'log' => [
            'traceLevel' => YII_DEBUG ? 3 : 0,
            'targets' => [
                [
                    'class' => 'yii\log\FileTarget',
                    'levels' => ['error', 'warning'],
                ],
            ],
        ],
        'session' => [
            'name' => 'BACKSESSID',
            'timeout' => 60 * 60,
            'cookieParams' => [
                // Solo mientras use http
                'secure' => false
            ]
        ],
        'urlManager' => [
            'enablePrettyUrl' => true,
            'showScriptName' => false,
            'rules' => [
                '<controller>/<id:\d+>' => '<controller>',
                '<controller>/<action>/<id:\d+>' => '<controller>/<action>',
                '<controller>/index' => '<controller>',
            ],
        ],
    ],
    'as access' => [
        'class' => 'yii\filters\AccessControl',
        'rules' => [
            /**
             *  Usuarios no logueados (rol ? )
             */
            [
                'allow' => true,
                'actions' => ['login', 'error'],
                'roles' => ['?'],
            ],
            /**
             *  Debug
             */
            [
                'allow' => true,
                'controllers' => ['debug', 'default', 'debug/default'],
            ],
            /**
             *  Usuarios logueados que deben cambiar contraseña
             */
            [
                'allow' => true,
                'actions' => ['cambiar-password', 'logout',],
                'roles' => ['@'],
            ],
            /**
             *  Usuarios logueados que no deben cambiar contraseña, están activos
             *  y tienen Token bueno
             */
            [
                'allow' => true,
                'roles' => ['@'],
                'matchCallback' => function () {
                    $usuario = Yii::$app->user->identity;
                    $token = Yii::$app->session->get('Token');
                    Yii::info('match callback');
                    return $usuario->DebeCambiarPass == 'N' && $usuario->Estado == 'A' && $usuario->Token == $token;
                },
            ],
        ],
        // Función que se ejecuta cuando el request es denegado.
        'denyCallback' => function ($rule, $action) {
            Yii::info('deny callback');
            if (!Yii::$app->user->isGuest) {
                if (Yii::$app->user->identity->DebeCambiarPass == 'S') {
                    //Redirect
                    Yii::$app->user->returnUrl = Yii::$app->request->referrer;
                    return $action->controller->redirect('/usuarios/cambiar-password');
                } else {
                    Yii::$app->user->logout();
                    Yii::$app->session->setFlash('danger', 'Ocurrió un problema con su sesión.');
                    Yii::$app->user->returnUrl = Yii::$app->request->referrer;
                    return $action->controller->redirect(Yii::$app->user->loginUrl);
                }
            }
            return $action->controller->redirect(Yii::$app->user->loginUrl);
        },
    ],
    'params' => $params,
];

if (YII_ENV_DEV) {
    // configuration adjustments for 'dev' environment
    $config['bootstrap'][] = 'debug';
    $config['modules']['debug'] = [
        'class' => 'yii\debug\Module',
        'allowedIPs' => ['*'],
    ];
}

return $config;
