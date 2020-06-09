<?php

namespace frontend\modules\api\controllers;

use yii\rest\Controller;

class BaseController extends Controller
{
    /**
     * @inheritdoc
     */
    public function actions()
    {
        return [
            'options' => [
                'class' => 'yii\rest\OptionsAction',
            ],
        ];
    }
}
