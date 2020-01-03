<?php

use common\models\Ventas;
use common\models\PuntosVenta;
use common\models\Proveedores;
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

$proveedor = new Proveedores();
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline']); ?>

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

            <?= $form->field($busqueda, 'Combo')->widget(Select2::classname(), [
                'data' => $clientes,
                'language' => 'es',
                'options' => ['placeholder' => 'Cliente'],
                'pluginOptions' => [
                    'allowClear' => true,
                    'width' => '343px'
                ],
            ]) ?>

            <?= $form->field($busqueda, 'Combo3')->dropDownList(Ventas::TIPOS, ['prompt' => 'Tipo', 'style' => 'margin-left: 10px']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?= $form->field($busqueda, 'Check')->checkbox(array('class' => 'check--buscar-form', 'label' => 'Incluir dados de baja', 'value' => 'S', 'uncheck' => 'N')); ?>

            <?= $form->field($busqueda, 'Check2')->checkbox(array('class' => 'check--buscar-form', 'label' => 'Incluir anulables', 'value' => 'S', 'uncheck' => 'N')); ?>

            <?php ActiveForm::end(); ?>
        </div>

        <?php if (PermisosHelper::tienePermiso('AltaVenta')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/ventas/alta','id' => $puntoventa['IdPuntoVenta']]) ?>"
                        data-hint="Nueva Venta">
                    Nueva Venta
                </button>
            </div>
        <?php endif; ?>

        <div id="errores"> </div>
        
        <?php if (count($models) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Cliente</th>
                                <th>Usuario</th>
                                <th>Monto</th>
                                <th>Fecha de Alta</th>
                                <th>Tipo</th>
                                <th>Canal</th>
                                <th>Estado</th>
                                <th>Tributo</th>
                                <th>Comprobante</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Cliente'] . ($model['ObservacionesCliente'] ? " [{$model['ObservacionesCliente']}]" : '') ) ?></td>
                                    <td><?= Html::encode($model['Usuario']) ?></td>
                                    <td><?= Html::encode($model['Monto']) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAlta'])) ?></td>
                                    <td><?= Html::encode(Ventas::TIPOS[$model['Tipo']]) ?></td>
                                    <td><?= Html::encode($model['Canal']) ?></td>
                                    <td><?= Html::encode(Ventas::ESTADOS[$model['Estado']]) ?></td>
                                    <td><?= Html::encode($model['TipoTributo']) ?></td>
                                    <td><?= Html::encode($model['TipoComprobanteAfip']) ?></td>
                                    <td><?= Html::encode($model['Observaciones']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if ($model['Estado'] == 'E') :?>
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
                                            <?php if ($model['Estado'] != 'B') : ?>
                                                <?php if ($model['Estado'] == 'E') :?>
                                                    <?php if (PermisosHelper::tienePermiso('ActivarVenta')): ?>
                                                        <button type="button" class="btn btn-default"
                                                                data-ajax="<?= Url::to(['ventas/activar', 'id' => $model['IdVenta']]) ?>"
                                                                data-hint="Completar">
                                                            <i class="fa fa-check-circle" style="color: green"></i>
                                                        </button>
                                                    <?php endif; ?>
                                                    <?php if (PermisosHelper::tienePermiso('BorrarVenta') && $anulable == 'S') : ?>
                                                        <button type="button" class="btn btn-default"
                                                                data-ajax="<?= Url::to(['/ventas/borrar', 'id' => $model['IdVenta']]) ?>"
                                                                data-hint="Borrar">
                                                            <i class="fa fa-trash"></i>
                                                        </button>
                                                    <?php endif; ?>
                                                <?php endif; ?>
                                                <?php if ($model['Estado'] == 'A' || $model['Estado'] == 'P') :?>
                                                    <?php if (PermisosHelper::tienePermiso('AltaVenta') && $model['Estado'] == 'P') : ?>
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
                                                    <?php if (PermisosHelper::tienePermiso('DevolucionVenta') && $anulable == 'N') : ?>
                                                        <button type="button" class="btn btn-default"
                                                                data-ajax="<?= Url::to(['ventas/devolucion', 'id' => $model['IdVenta']]) ?>"
                                                                data-hint="Devolucion">
                                                            <i class="fa fa-undo-alt"></i>
                                                        </button>
                                                    <?php endif; ?>
                                                <?php endif; ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaVenta') && $anulable == 'S') : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['ventas/dar-baja', 'id' => $model['IdVenta']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
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
            <p><strong>No hay Ventas que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>