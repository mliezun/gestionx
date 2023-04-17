<?php

namespace backend\controllers;

use Yii;

class StatusController extends BaseController
{
    public function actionIndex()
    {
        $sql = "SELECT 'OK'";

        $query = Yii::$app->db->createCommand($sql);

        return $query->queryScalar();
    }
}
