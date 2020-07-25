<?php

namespace common\helpers;

use Yii;
use yii\web\Response;

class YiiHelper
{
    /**
     * Setea el formato de respuesta como JSON. Encodea automáticamente los datos retornados.
     */
    public static function setJsonResponseFormat()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
    }
}
