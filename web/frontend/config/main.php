<?php
$params = array_merge(
    require __DIR__ . '/../../common/config/params.php',
    require __DIR__ . '/../../common/config/params-local.php',
    require __DIR__ . '/params.php',
    require __DIR__ . '/params-local.php'
);

$config = [
    'id' => 'gestionx-frontend',
    'name' => 'GestionX Frontend',
    'basePath' => dirname(__DIR__),
    'controllerNamespace' => 'frontend\controllers',
    'bootstrap' => ['frontend\modules\api\Bootstrap', 'log'],
    'modules' => [
        'api' => [
            'class' => 'frontend\modules\api\Api',
        ],
    ],
    'components' => [
        'request' => [
            'csrfParam' => 'front_csrf',
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
            'name' => 'FRONTSESSID',
            'timeout' => 60 * 60,
            'cookieParams' => [
                'secure' => true
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
                'roles' => ['?'],
            ],
        ],
    ],
    'params' => $params,
];

if (YII_ENV_DEV) {
    // configuration adjustments for 'dev' environment
    $config['bootstrap'][] = 'debug';
    $config['modules']['debug'] = [
        'class' => 'yii\debug\Module',
        'allowedIPs' => ['127.0.0.1'],
    ];
}

return $config;
