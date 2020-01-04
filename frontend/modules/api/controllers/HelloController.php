<?php
namespace frontend\modules\api\controllers;

use Yii;

class HelloController extends BaseController
{
    /**
     * @api {get} /hello Hello
     * @apiName Hello
     * @apiGroup Hello
     * 
     * @apiError {String} Error Mensaje de error.
     */
    public function actionIndex()
    {
        return ['Error' => null];
    }
}
