<?php

use common\models\Proveedores;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use kartik\date\DatePicker;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\LinkPager;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Cuentas del Proveedor: '. $proveedor['Proveedor'];
$this->params['breadcrumbs'][] = [
    'label' => 'Proveedores',
    'link' => '/proveedores'
];
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline', 'method' => 'GET']); ?>

            <?= $form->field($busqueda, 'FechaInicio')->widget(DatePicker::classname(), [
            'options' => ['placeholder' => 'Fecha desde'],
            'type' => DatePicker::TYPE_INPUT,
            'pluginOptions' => [
                'autoclose'=> true,
                'format' => 'dd/mm/yyyy'
            ]
            ]) ?>

            <?= $form->field($busqueda, 'FechaFin')->widget(DatePicker::classname(), [
                'options' => ['placeholder' => 'Fecha hasta'],
                'type' => DatePicker::TYPE_INPUT,
                'pluginOptions' => [
                    'autoclose'=> true,
                    'format' => 'dd/mm/yyyy'
                ]
            ]) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        <?php if (Yii::$app->user->identity->IdEmpresa == 1) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/pagos/alta-proveedor', 'id' => $proveedor['IdProveedor']]) ?>"
                        data-hint="Nuevo Precio por Lista">
                    Nuevo Pago al Proveedor
                </button>
            </div>
        <?php endif; ?>

        <div id="errores"> </div>
        
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Proveedor</th>
                                <th>Descuento</th>
                                <th>Estado</th>
                                <?php if (Yii::$app->user->identity->IdEmpresa == 1) : ?>
                                    <th>Deuda</th>
                                <?php endif; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><?= Html::encode($proveedor['Proveedor']) ?></td>
                                <td>% <?= Html::encode($proveedor['Descuento']) ?></td>
                                <td><?= Html::encode(Proveedores::ESTADOS[$proveedor['Estado']]) ?></td>
                                <?php if (Yii::$app->user->identity->IdEmpresa == 1) : ?>
                                    <?php
                                    $deuda = $proveedor['Deuda'] ?? 0;
                                    $estilo = '';
                                    if ($deuda > 0) {
                                        $estilo = ' style="color: red; font-weight: bold; font-size: 20px" ';
                                    } elseif($deuda < 0) {
                                        $estilo = ' style="color: green; font-weight: bold; font-size: 20px" ';
                                    } else {
                                        $estilo = ' style="color: green; font-weight: bold" ';
                                    }
                                    echo "<td $estilo>";
                                    echo Html::encode($deuda);
                                    echo '</td>';
                                    ?>
                                <?php endif; ?>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <?php if (count($models) > 0): ?>
            <div class="card">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table">
                            <thead class="bg-light">
                                <tr class="border-0">
                                    <th>Fecha</th>
                                    <th>Motivo</th>
                                    <th>Monto</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($models as $k=>$model): ?>
                                    <tr>
                                        <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['Fecha'])) ?></td>
                                        <td><?= Html::encode($model['Motivo']) ?></td>
                                        <td><?= Html::encode( - $model['Monto']) ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="pull-right">
                <?=
                    LinkPager::widget([
                        'pagination' => $paginado,
                        'firstPageLabel' => '<<',
                        'lastPageLabel' => '>> ',
                        'nextPageLabel' => '>',
                        'prevPageLabel' => '<',
                        'pageCssClass' => 'page-link',
                        'activePageCssClass' => 'page-item-active',
                        'firstPageCssClass' => 'page-link',
                        'lastPageCssClass' => 'page-link',
                        'nextPageCssClass' => 'page-link',
                        'prevPageCssClass' => 'page-link',
                    ]);
                ?>
            </div>
            <div class="clearfix"></div>
        <?php else: ?>
            <p><strong>No hay un historial de cuentas que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>