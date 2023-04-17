<?php

namespace backend\controllers;

use Yii;

class StatusController extends BaseController
{
    public function actionHealth()
    {
        Yii::$app->response->format = 'json';

        $sql = "SELECT 'OK'";

        $query = Yii::$app->db->createCommand($sql);

        return $query->queryScalar();
    }
}
