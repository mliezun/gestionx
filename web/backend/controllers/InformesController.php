<?php

namespace backend\controllers;

use common\models\GestorInformes;
use Yii;

class InformesController extends BaseController
{
    public function actionTablas()
    {
        Yii::$app->response->format = 'json';
        $gestor = new GestorInformes;

        return $gestor->ListarTablas();
    }

    public function actionInforme()
    {
        $informe = Yii::$app->request->post();
        /*
        $informe = [
            'SELECT' => [
                'Tabla1' => [
                    'ColumnaX',
                    'ColumnaY'
                ],
                'Tabla2' => [
                    'ColumnaZ',
                    'ColumnaT'
                ],
                'Tabla3' => [
                    'ColumnaH',
                    'ColumnaW'
                ]
            ],
            'FROM' => [
                'Tabla1' => [
                    'ColumnaX'
                ],
                'Tabla2' => [
                    'ColumnaX'
                ],
                'Tabla3' => [
                    'ColumnaT'
                ]
            ],
            'WHERE' => [
                'Tabla1' => [
                    'ColumnaY' => '> 10',
                    'ColumnaX' => '= "T"'
                ],
                'Tabla3' => [
                    'ColumnaH' => '> "2020-01-01"'
                ]
            ]
        ]
        */
    }
}

?>