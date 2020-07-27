<?php

namespace backend\controllers;

use common\models\GestorInformes;
use Yii;
use yii\base\DynamicModel;
use yii\helpers\ArrayHelper;
use yii\web\Controller;
use yii\web\HttpException;
use common\models\GestorReportes;
use common\components\PermisosHelper;
use common\components\AppHelper;
use common\components\FechaHelper;
use common\components\CmdHelper;

class InformesController extends BaseController
{
    public function actionIndex($id = null, $key = null)
    {
        // PermisosHelper::verificarPermiso($reporte['Reporte']);

        ini_set("memory_limit", "1024M");
        $gestor = new GestorReportes();

        $menu = $gestor->ListarMenu();
        $model = null;
        $reporte = null;
        $parametros = null;
        $tabla = null;

        if (intval($id)) {
            $reporte = $gestor->DameModeloReporte($id);

            if (!Yii::$app->request->isPost) {
                $parametros = $gestor->DameParametrosModeloReporte($id);

                $model = new DynamicModel(ArrayHelper::map($parametros, 'Parametro', 'ValorDefecto'));

                if ($key != null && Yii::$app->cache->get($key)) {
                    $model = Yii::$app->cache->get($key)['model'];
                    $tabla = Yii::$app->cache->get($key)['resultado'];
                }
            } else {
                $parametros = $gestor->DameParametrosModeloReporte($id, 'P');

                $model = new DynamicModel(ArrayHelper::getColumn($parametros, 'Parametro'));

                $model->addRule($model->attributes(), 'safe');

                // Agrego reglas de validación
                foreach ($parametros as $parametro) {
                    if ($parametro['Tipo'] == 'E') {
                        $model->addRule($parametro['Parametro'], 'entero');
                    } elseif ($parametro['Tipo'] == 'M') {
                        $model->addRule($parametro['Parametro'], 'decimal', ['min' => 0]);
                    }
                }

                if (count($parametros) == 0 || $model->load(Yii::$app->request->post()) && $model->validate()) {
                    $valores = [];

                    foreach ($parametros as $parametro) {
                        if ($parametro['Tipo'] == 'F') {
                            $valor = FechaHelper::formatearDateMysql($model->{$parametro['Parametro']});
                        } elseif ($parametro['Tipo'] == 'H') {
                            $valor = FechaHelper::formatearDatetimeMysql($model->{$parametro['Parametro']});
                        } else {
                            $valor = $model->{$parametro['Parametro']};
                        }

                        if (!isset($valor)) {
                            $valores[] = "null";
                        } else {
                            $valores[] = "'$valor'";
                        }
                    }

                    $key = $this->generarKey();
                    $idReporte = $reporte['IdModeloReporte'];
                    $cadena = implode(',', $valores);

                    $tabla = Yii::$app->cache->set($key, [
                        'model' => $model,
                        'resultado' => null,
                    ]);

                    $IdEmpresa = Yii::$app->user->identity->IdEmpresa;
                    $comando = "informes/generar '{$IdEmpresa}' '$key' '$idReporte' \"$cadena\"";

                    CmdHelper::exec([
                        "php " . Yii::getAlias("@webroot/../../yii") . " " . $comando
                    ]);
                    

                    AppHelper::setJsonResponseFormat();
                    return [
                        'error' => null,
                        'key' => $key
                    ];
                }
            }
        }

        return $this->render('index', [
                    'menu' => $menu,
                    'model' => $model,
                    'reporte' => $reporte,
                    'parametros' => $parametros,
                    'tabla' => $tabla,
        ]);
    }

    private function generarKey(): string
    {
        $key = Yii::$app->security->generateRandomString();
        $key = str_replace('-', 'x', $key);
        return $key;
    }

    public function actionEstado($key)
    {
        AppHelper::setJsonResponseFormat();

        $resultado = Yii::$app->cache->get($key)['resultado'];

        return ['ready' => $resultado != null || is_array($resultado)];
    }

    public function actionAutocompletar($idModeloReporte, $nroParametro, $id = 0, $cadena = '')
    {
        AppHelper::setJsonResponseFormat();

        $gestor = new GestorReportes();

        if ($id != 0) {
            $nombre = $gestor->DameParametroListado($idModeloReporte, $nroParametro, $id)['Nombre'];

            $out = ['id' => $id, 'text' => $nombre];
        } else {
            if (strlen($cadena) > 3) {
                $elementos = $gestor->LlenarListadoParametro($idModeloReporte, $nroParametro, $cadena);

                $out = array();

                foreach ($elementos as $elemento) {
                    $out[] = ['id' => $elemento['Id'], 'text' => $elemento['Nombre']];
                }
            } else {
                $out = ['id' => '0', 'text' => "Ingresar más de 4 caracteres."];
            }
        }

        return $out;
    }

    public function actionExcel($id, $key)
    {
        ini_set("memory_limit", "1024M");

        if (!intval($id) || !Yii::$app->cache->get($key)) {
            throw new HttpException('422', "El informe es inválido.");
        }

        $gestor = new GestorReportes();
        $reporte = $gestor->DameModeloReporte($id);

        $tabla = Yii::$app->cache->get($key)['resultado'];

        // Create new PHPExcel object
        $objPHPExcel = new \PHPExcel();

        // Fill worksheet from values in array
        $objPHPExcel->getActiveSheet()->fromArray($tabla, null, 'A2');

        // Rename worksheet
        $objPHPExcel->getActiveSheet()->setTitle('Informe');

        // Set AutoSize
        for ($i = 0; $i < count($tabla[0]); $i++) {
            $objPHPExcel->getActiveSheet()->setCellValueByColumnAndRow($i, 1, array_keys($tabla[0])[$i]);
            $objPHPExcel->getActiveSheet()->getColumnDimensionByColumn($i)->setAutoSize(true);
        }

        $objPHPExcel->getActiveSheet()->freezePane('A2');

        header('Content-Type: application/vnd.ms-excel');
        $filename = $reporte['NombreMenu'] . ".xls";
        header('Content-Disposition: attachment;filename=' . $filename . ' ');
        header('Cache-Control: max-age=0');

        // Save Excel 2007 file
        $objWriter = \PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
        ob_end_clean();
        $objWriter->save('php://output');
    }

    public function actionDescargar($key, $nombre)
    {
        $file = Yii::$app->cache->get($key)['tabla'];
        return Yii::$app->response->sendContentAsFile($file, $nombre . '.csv')->send();
    }

    public function actionEstadoTabla($key)
    {
        AppHelper::setJsonResponseFormat();

        $resultado = Yii::$app->cache->get($key)['tabla'];

        return ['ready' => $resultado != null || is_array($resultado)];
    }

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
