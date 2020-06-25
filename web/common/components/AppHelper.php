<?php

namespace common\components;

use Yii;

class AppHelper
{
    /**
     * Setea el formato de respuesta como JSON. Encodea automáticamente los datos retornados.
     * Equivalente a \common\components\AppHelper::setJsonResponseFormat();
     */
    public static function setJsonResponseFormat()
    {
        Yii::$app->response->format = Response::FORMAT_JSON;
    }
}
