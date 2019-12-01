<?php

use common\models\Clientes;
use common\models\Ventas;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use kartik\date\DatePicker;
use kartik\select2\Select2;
use yii\widgets\LinkPager;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Ventas de clientes';
$this->params['breadcrumbs'][] = [
    'label' => 'Clientes',
    'link' => '/clientes'
];
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline']); ?>

            <?php if (!$ocultarId): ?>
            <?= $form->field($busqueda, 'Id')->widget(Select2::classname(), [
                'data' => $clientes,
                'language' => 'es',
                'options' => ['placeholder' => 'Cliente'],
                'pluginOptions' => [
                    'allowClear' => true,
                    'width' => '243px'
                ],
            ]) ?>
            <?php endif; ?>

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

            <?= $form->field($busqueda, 'Combo')->dropDownList(Clientes::ESTADOS, ['prompt' => 'Estado de cliente']) ?>

            <?= $form->field($busqueda, 'Combo2')->dropDownList(Ventas::ESTADOS, ['prompt' => 'Estado venta']) ?>

            <?= $form->field($busqueda, 'Combo3')->dropDownList(['S' => 'En mora', 'N' => 'Todas'], ['prompt' => 'Mora']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        <div id="errores"> </div>
        
        <?php if (count($models) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Nombre</th>
                                <th>Fecha de venta</th>
                                <th>Tipo de venta</th>
                                <th>Estado de venta</th>
                                <th>Monto de venta</th>
                                <th>Monto pagado</th>
                                <th>Deuda</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode(Clientes::Nombre($model)) . ($model['Observaciones'] ? " [{$model['Observaciones']}]" : '') ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAltaVenta'])) ?></td>
                                    <td><?= Html::encode(Ventas::TIPOS[$model['TipoVenta']]) ?></td>
                                    <td><?= Html::encode(Ventas::ESTADOS[$model['EstadoVenta']]) ?></td>
                                    <td><?= Html::encode($model['Monto']) ?></td>
                                    <td><?= Html::encode($model['MontoPagos']) ?></td>
                                    <?php
                                        $deuda = $model['Monto'] - $model['MontoPagos'];
                                        $estilo = '';
                                        if ($deuda > 0 && $model['EstadoVenta'] == 'A') {
                                            $estilo = ' style="color: red; font-weight: bold; font-size: 20px" ';
                                        }
                                        echo "<td $estilo>";
                                        echo Html::encode($deuda);
                                        echo '</td>';
                                    ?>
                                    <td><?= Html::encode($model['ObservacionesVenta']) ?></td>
                                    <td>

                                    <div class="btn-group" role="group" aria-label="...">
                                            <?php if (PermisosHelper::tienePermiso('BuscarPuntosVenta')) : ?>
                                                <a class="btn btn-default"
                                                        href="<?= Url::to(['/puntos-venta/operaciones', 'id' => $model['IdPuntoVenta']]) ?>" 
                                                        data-hint="Punto de venta">
                                                    <i class="fas fa-store" style="color: gold"></i>
                                                </a>
                                            <?php endif; ?>
                                            <?php if ($model['EstadoVenta'] == 'E') :?>
                                                <?php if (PermisosHelper::tienePermiso('AltaLineaVenta')) : ?>
                                                    <a class="btn btn-default"
                                                            href="<?= Url::to(['/ventas/lineas', 'id' => $model['IdVenta']]) ?>" 
                                                            data-hint="Lineas">
                                                        <i class="fas fa-clipboard-list"></i>
                                                    </a>
                                                <?php endif; ?>
                                                <?php if (PermisosHelper::tienePermiso('ModificarVenta')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-modal="<?= Url::to(['ventas/editar', 'id' => $model['IdVenta']]) ?>"
                                                            data-hint="Modificar">
                                                        <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if ($model['EstadoVenta'] != 'B') : ?>
                                                <?php if ($model['EstadoVenta'] == 'E') :?>
                                                    <?php if (PermisosHelper::tienePermiso('ActivarVenta')): ?>
                                                        <button type="button" class="btn btn-default"
                                                                data-ajax="<?= Url::to(['ventas/activar', 'id' => $model['IdVenta']]) ?>"
                                                                data-hint="Completar">
                                                            <i class="fa fa-check-circle" style="color: green"></i>
                                                        </button>
                                                    <?php endif; ?>
                                                <?php endif; ?>
                                                <?php if ($model['EstadoVenta'] == 'A' || $model['EstadoVenta'] == 'P') :?>
                                                    <?php if (PermisosHelper::tienePermiso('AltaVenta') && $model['EstadoVenta'] == 'P') : ?>
                                                        <a class="btn btn-default"
                                                                href="<?= Url::to(['/ventas/comprobante', 'id' => $model['IdVenta']]) ?>"
                                                                target="_blank"
                                                                data-hint="Imprimir Factura">
                                                            <i class="fas fa-print"></i>
                                                        </a>
                                                    <?php endif; ?>
                                                    <?php if (PermisosHelper::algunPermisoContiene('PagarVenta')) : ?>
                                                        <a class="btn btn-default"
                                                                href="<?= Url::to(['/pagos', 'id' => $model['IdVenta']]) ?>"
                                                                data-hint="Pagos">
                                                            <i class="fas fa-money-bill-wave"></i>
                                                        </a>
                                                    <?php endif; ?>
                                                <?php endif; ?>
                                            <?php endif; ?>   
                                        </div>
                                    </td> 
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
            <p><strong>No hay clientes que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>