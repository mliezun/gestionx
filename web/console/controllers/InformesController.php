<?php

namespace console\controllers;

use Yii;
use yii\console\Controller;
use common\models\GestorReportes;

class InformesController extends Controller
{
    public function actionGenerar($key, $idReporte, $valores)
    {
        $gestor = new GestorReportes();

        $resultado = Yii::$app->cache->get($key);

        $resultado['resultado'] = $gestor->Ejecutar($idReporte, $valores);

        Yii::$app->cache->set($key, $resultado, 3600);
    }

    public function actionDetallePartido($key, $IdPartido)
    {
        $gestor = new GestorReportes();

        $resultado = Yii::$app->cache->get($key);

        $resultado['resultado'] = $gestor->DetallePartido($IdPartido);

        Yii::$app->cache->set($key, $resultado, 300);
    }

    public function actionPartidoCsv($key)
    {
        set_time_limit(600);
        ini_set("memory_limit", "1024M");
        $model = Yii::$app->cache->get($key);
        $tabla = Yii::$app->cache->get($key)['resultado'];
        $file = '';
        foreach ($tabla[0] as $titulo => $valor) {
            $file = $file . $titulo;
        }
        foreach ($tabla as $linea) {
            foreach ($linea as $field) {
                $file = $file . $field;
            }
        }
        $model['tabla'] = $file;
        Yii::$app->cache->set($key, $model, 300);
        set_time_limit(30);
        ini_set("memory_limit", "128M");
    }
}
