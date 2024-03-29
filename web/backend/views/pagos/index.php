<?php

use common\models\Pagos;
use common\models\Ingresos;
use common\helpers\PermisosHelper;
use common\helpers\FechaHelper;
use common\helpers\FormatoHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\LinkPager;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = $titulo;
$this->params['breadcrumbs'][] = $anterior;
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline']); ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(Pagos::MEDIOS_PAGO, ['prompt' => 'Tipo']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>
        <?php if (/* PermisosHelper::tienePermiso('PagarVenta') && */ $model['Estado'] != 'P') : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/pagos/alta', 'id' => $model['IdVenta'], 'tipo' => 'V']) ?>"
                        data-hint="Nuevo Pago">
                    Nuevo Pago
                </button>
            </div>
        <?php endif; ?>

        <div id="errores"> </div>
        
        <?php if (count($pagos) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Medio de Pago</th>
                                <th>Monto</th>
                                <th>Datos</th>
                                <th>Fecha de Alta</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($pagos as $pago): ?>
                                <tr>
                                    <td><?= Html::encode($pago['MedioPago']) ?></td>
                                    <td><?= Html::encode(FormatoHelper::formatearMonto($pago['Monto'])) ?></td>
                                    <td>
                                        <ul>
                                        <?php if ($pago['MedioPago'] == 'Tarjeta') : ?>
                                            <li><?= Html::encode('Nro de Tarjeta') ?>: <?= Html::encode($pago['NroTarjeta']) ?></li>
                                            <li><?= Html::encode('Mes de Vencimiento') ?>: <?= Html::encode($pago['MesVencimiento']) ?></li>
                                            <li><?= Html::encode('Año de Vencimiento') ?>: <?= Html::encode($pago['AnioVencimiento']) ?></li>
                                            <li><?= Html::encode('CCV') ?>: <?= Html::encode($pago['CCV']) ?></li>
                                        <?php endif; ?>
                                        <?php if ($pago['MedioPago'] == 'Mercaderia') : ?>
                                            <?php
                                                $lineas = [];
                                                $ingreso = new Ingresos;
                                                $ingreso->setAttributes(json_decode($pago['Datos'], true));
                                                $lineas = $ingreso->DameLineas();
                                            ?>
                                            <?php foreach ($lineas as $linea): ?>
                                                <li><?= Html::encode('Articulo') ?>: <?= Html::encode($linea['Articulo']) ?></li>
                                                <li><?= Html::encode('Cantidad') ?>: <?= Html::encode($linea['Cantidad']) ?></li>
                                                <li><?= Html::encode('Precio') ?>: <?= Html::encode(FormatoHelper::formatearMonto($linea['Precio'])) ?></li>
                                            <?php endforeach; ?>
                                        <?php endif; ?>
                                        <?php if ($pago['MedioPago'] == 'Cheque') : ?>
                                            <li><?= Html::encode('Nro de Cheque') ?>: <?= Html::encode($pago['NroCheque']) ?></li>
                                        <?php endif; ?>
                                        <?php if ($pago['MedioPago'] == 'Retencion') : ?>
                                            <li><?= Html::encode('Tipo de Tributo') ?>: <?= Html::encode($tributos[json_decode($pago['Datos'])->IdTipoTributo]) ?></li>
                                        <?php endif; ?>
                                        <?php if ($pago['MedioPago'] == 'Descuento') : ?>
                                            <li><?= Html::encode('Descuento') ?>: % <?= Html::encode(($pago['Monto'] / $model['Monto']) * 100) ?></li>
                                        <?php endif; ?>
                                        </ul>
                                    </td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($pago['FechaAlta'])) ?></td>
                                    <td><?= Html::encode($pago['Observaciones']) ?></td>
                                    <td>
                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if (PermisosHelper::tienePermiso('PagarVenta')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['pagos/editar', 'id' => $pago['IdPago'], 'tipo' => 'V']) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarPagoVenta')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-mensaje="¿Desea borrar el pago?"
                                                        data-ajax="<?= Url::to(['pagos/borrar', 'id' => $pago['IdPago'], 'tipo' => 'V']) ?>"
                                                        data-hint="Borrar">
                                                    <i class="fa fa-trash"></i>
                                                </button>
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
            <p><strong>No hay pagos que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
        <?php if ($model['Estado'] != 'P') : ?>
        <div class="lineas--bottom">
            <div class="lineas--total">
                Total de la Venta: <?= Html::encode(FormatoHelper::formatearMonto($model['Monto'])) ?>
            </div>
            <div class="lineas--total">
                Restante: <?= Html::encode(FormatoHelper::formatearMonto($model['Monto'] - $model['MontoPagado'])) ?>
            </div>
            <div class="lineas--total">
                Total de los Pagos: <?= Html::encode(FormatoHelper::formatearMonto($model['MontoPagado'])) ?>
            </div>
        </div>
        <?php else: ?>
        <div class="lineas--bottom">
            <div class="lineas--total">
                PAGADO
            </div>
        </div>
        <?php if (PermisosHelper::tienePermiso('AltaVenta')) : ?>
            <button type="button" class="btn btn-primary"
                    data-ajax="<?= Url::to(['/ventas/enviar-comprobante', 'id' => $model['IdVenta']]) ?>"
                    data-hint="Enviar Factura">
                ENVIAR
            </button>
            <a class="btn btn-secondary"
                    href="<?= Url::to(['/ventas/comprobante', 'id' => $model['IdVenta']]) ?>"
                    target="_blank"
                    data-hint="Imprimir Factura">
                IMPRIMIR
            </a>
        <?php endif; ?>
        <?php endif; ?>
    </div>
</div>