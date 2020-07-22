<?php
namespace frontend\controllers;

use yii\web\Controller;

/**
 * Privacy controller
 */
class PrivacyController extends Controller
{
    public function actionIndex()
    {
        return $this->render('index');
    }
}
