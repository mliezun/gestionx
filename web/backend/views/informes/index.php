<?php

use yii\helpers\Html;
use yii\helpers\Url;
use yii\bootstrap\ActiveForm;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use common\components\NinjaArrayHelper;

\backend\assets\InformesAsset::register($this);
$this->registerJs('Informes.init()');

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $menu [] */
/* @var $reporte [] */
/* @var $parametros [] */

$this->title = "Informes";
$this->params['breadcrumbs'][] = $this->title;

function buscar_hojas($menu)
{
    $out = array();
    foreach ($menu as $elemento) {
        if ($elemento['EsHoja'] == 'S') {
            $out[] = $elemento;
        }
    }
    return $out;
}

$reportes = buscar_hojas($menu);
?>

<div style="margin-bottom: 30px">
    <?php foreach ($reportes as $r): ?>
    <div style="margin-bottom: 10px">
        <a class="btn btn-secondary" data-hint="<?= $r['Ayuda'] ?>" href="<?= URL::to(['/informes', 'id' => $r['IdModeloReporte']]) ?>">
            <?= $r['NombreMenu'] ?>
        </a>
    </div>
    <?php endforeach; ?>
</div>

<?php if ($reporte != null): ?>

<div class="box" id="informes">

    <div class="overlay" v-show="cargando" v-cloak>
        <div>
            <i class="fas fa-sync fa-spin fa-5x" style="color: white;"></i>
        </div>
    </div>

    <div class="box-header">
        <h3 class="box-title"><?= $reporte['NombreMenu'] ?>
        </h3>
    </div>
    <div class="box-body">

        <p><?= $reporte['Ayuda'] ?>
        </p>

        <div class="top10">
            <?php
                $form = ActiveForm::begin([
                            'options' => ['ref' => 'forminformes'],
                            'layout' => 'horizontal'
                        ])
                ?>

            <?php
                foreach ($parametros as $parametro) {
                    switch ($parametro['Tipo']) {
                        case 'E':
                            echo $this->render('inputs/entero', [
                                'model' => $model,
                                'form' => $form,
                                'parametro' => $parametro
                            ]);
                            break;
                        case 'L':
                            echo $this->render('inputs/listado', [
                                'model' => $model,
                                'form' => $form,
                                'parametro' => $parametro
                            ]);
                            break;
                        case 'F':
                            echo $this->render('inputs/fecha', [
                                'model' => $model,
                                'form' => $form,
                                'parametro' => $parametro
                            ]);
                            break;
                        case 'H':
                            echo $this->render('inputs/fechahora', [
                                'model' => $model,
                                'form' => $form,
                                'parametro' => $parametro
                            ]);
                            break;
                        case 'A':
                            echo $this->render('inputs/autocompletado', [
                                'model' => $model,
                                'form' => $form,
                                'parametro' => $parametro
                            ]);
                            break;
                        case 'M':
                            echo $this->render('inputs/moneda', [
                                'model' => $model,
                                'form' => $form,
                                'parametro' => $parametro
                            ]);
                            break;
                        case 'O':
                            echo $this->render('inputs/opcion', [
                                'model' => $model,
                                'form' => $form,
                                'parametro' => $parametro
                            ]);
                            break;
                        default:
                            echo $this->render('inputs/cadena', [
                                'model' => $model,
                                'form' => $form,
                                'parametro' => $parametro
                            ]);
                    }
                }
                ?>
            <?php ActiveForm::end(); ?>

            <button class="btn btn-primary pull-right no-print" @click="generarInforme( <?= $reporte['IdModeloReporte'] ?>)">
                <i class="fa fa-play"></i> <?= "Ejecutar" ?>
            </button>

        </div>

        <?php if ($tabla != null) : ?>
        <div class="clearfix"></div>

        <a class="btn btn-default pull-left no-print" href="/informes/excel/<?= $reporte['IdModeloReporte'] ?>?key=<?= Yii::$app->request->get('key') ?>">
            <i class="fa fa-file-excel-o"></i> <?= "Exportar a Excel" ?>
        </a>

        <button class="btn btn-default pull-left no-print" onclick="Main.imprimir();">
            <i class="fa fa-print"></i> <?= "Imprimir" ?>
        </button>
        <?php endif; ?>

        <div class="clearfix"></div>

        <div style="max-width: 80vw; z-index: -1" v-show="!cargando">
            <?php if (isset($tabla)) : ?>
            <?php if (count($tabla) > 0): ?>
            <table id="tabla-informe" class="table table-bordered table-hover table-condensed ">
                <thead style="background-color: white">
                    <tr>
                        <?php foreach ($tabla[0] as $titulo => $valor): ?>
                        <th>
                            <?php
                            $patrones = [$reporte['Procedimiento'] . '.Columnas', 'columnas_informe'];
                            echo Html::encode($titulo)
                            ?>
                        </th>
                        <?php endforeach; ?>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($tabla as $fila): ?>
                    <tr class="no-break">
                        <?php foreach ($fila as $columna => $celda): ?>
                        <td>
                            <?php
                                $patrones = [$reporte['Procedimiento'] . '.' . $columna];
                                if (strpos($columna, '$') !== false) {
                                    $patrones = array_merge($patrones, [$reporte['Procedimiento'] . '.$', '$']);
                                } elseif (strpos($columna, '%') !== false) {
                                    $patrones = array_merge($patrones, [$reporte['Procedimiento'] . '.%', '%']);
                                } elseif (strpos($columna, '#') !== false) {
                                    $patrones = array_merge($patrones, [$reporte['Procedimiento'] . '.#', '#']);
                                }
                                if (strpos($columna, 'Fecha') !== false) {
                                    echo isset($celda) ? FechaHelper::formatearDatetimeLocal($celda) : '';
                                } else {
                                    echo isset($celda) ? $celda : '';
                                }
                            ?>
                        </td>
                        <?php endforeach; ?>
                    </tr>
                    <?php endforeach; ?>
                </tbody>

            </table>
            <?php else: ?>
            <p><strong><?= "No hay resultados que coincidan con los criterios seleccionados." ?></strong></p>
            <?php endif; ?>
            <?php endif; ?>
        </div>
    </div>

</div>
<?php endif; ?>
