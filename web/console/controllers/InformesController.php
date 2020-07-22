<?php

namespace console\controllers;

use Yii;
use yii\console\Controller;
use common\models\GestorReportes;

class InformesController extends Controller
{
    public function actionGenerar($IdEmpresa, $key, $idReporte, $valores)
    {
        $gestor = new GestorReportes();

        $resultado = Yii::$app->cache->get($key);

        $resultado['resultado'] = $gestor->Ejecutar($IdEmpresa, $idReporte, $valores);

        Yii::$app->cache->set($key, $resultado, 3600);
    }
}
