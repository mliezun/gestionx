<?php

namespace frontend\modules\api;

use Yii;
use yii\base\Module;
use yii\filters\AccessControl;
use yii\filters\Cors;
use yii\filters\RateLimiter;
use common\models\Usuarios;
use common\models\IPRateLimiter;

class Api extends Module
{
    public $controllerNamespace = 'frontend\modules\api\controllers';

    public function init()
    {
        Yii::$app->id = 'api-gestionx';
        Yii::$app->user->loginUrl = null;
        Yii::$app->errorHandler->errorAction = null;
        
        Yii::$app->attachBehavior('access', [
            'class' => AccessControl::className(),
            'rules' => [
                    [
                    'allow' => true,
                    'roles' => ['?', '@'],
                ],
            ],
        ]);
        
        parent::init();
    }

    public function behaviors()
    {
        return [
            'corsFilter' => [
                'class' => Cors::className(),
                'cors' => [
                    'Origin' => ['*'],
                    'Access-Control-Allow-Credentials' => false,
                    'Access-Control-Request-Method' => ['GET', 'DELETE', 'POST', 'PATCH', 'OPTIONS', 'PUT'],
                    'Access-Control-Request-Headers' => ['Authorization', 'Content-Type'],
                    'Access-Control-Allow-Headers' => ['Authorization', 'Content-Type']
                ],
            ]
        ];
    }
}
