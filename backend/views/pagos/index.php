<?php

use common\models\Pagos;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

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

            <?= $form->field($busqueda, 'Combo')->dropDownList(Pagos::TIPOS, ['prompt' => 'Tipo']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>
        <?php if (PermisosHelper::tienePermiso('PagarVenta')) : ?>
            <div class="alta--button">
                <?php if (PermisosHelper::tienePermiso('PagarVentaEfectivo')) : ?>
                    <button type="button" class="btn btn-primary"
                            data-modal="<?= Url::to(['/pagos/alta', 'id' => $model['IdVenta'], 'Tipo' => 'E', 'Prueba'=> 'GG']) ?>"
                            data-hint="Nuevo Pago con Efectivo">
                        Nuevo Pago con Efectivo
                    </button>
                <?php endif; ?>
                <?php if (PermisosHelper::tienePermiso('PagarVentaTarjeta')) : ?>
                    <button type="button" class="btn btn-secondary"
                            data-modal="<?= Url::to(['/pagos/alta', 'id' => $model['IdVenta'], 'Tipo' => 'T']) ?>"
                            data-hint="Nuevo Pago con Tarjeta">
                        Nuevo Pago con Tarjeta
                    </button>
                <?php endif; ?>
                <?php if (PermisosHelper::tienePermiso('PagarVentaMercaderia')) : ?>
                    <button type="button" class="btn btn-primary"
                            data-modal="<?= Url::to(['/pagos/alta', 'id' => $model['IdVenta'], 'Tipo' => 'M']) ?>"
                            data-hint="Nuevo Pago con Mercaderia">
                        Nuevo Pago con Mercaderia
                    </button>
                <?php endif; ?>
                <?php if (PermisosHelper::tienePermiso('PagarVentaCheque')) : ?>
                    <button type="button" class="btn btn-secondary"
                            data-modal="<?= Url::to(['/pagos/alta', 'id' => $model['IdVenta'], 'Tipo' => 'C']) ?>"
                            data-hint="Nuevo Pago con Cheque">
                        Nuevo Pago con Cheque
                    </button>
                <?php endif; ?>
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
                                <th>Tipo de Comprobante</th>
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
                                    <td><?= Html::encode($pago['TipoComprobante']) ?></td>
                                    <td><?= Html::encode($pago['Monto']) ?></td>
                                    <td>
                                        <ul>
                                        <?php if ($pago['MedioPago'] == 'Tarjeta') : ?>
                                            <li><?= Html::encode('Nro de Tarjeta') ?>: <?= Html::encode($pago['NroTarjeta']) ?></li>
                                            <li><?= Html::encode('Mes de Vencimiento') ?>: <?= Html::encode($pago['MesVencimiento']) ?></li>
                                            <li><?= Html::encode('Año de Vencimiento') ?>: <?= Html::encode($pago['AnioVencimiento']) ?></li>
                                            <li><?= Html::encode('CCV') ?>: <?= Html::encode($pago['CCV']) ?></li>
                                        <?php endif; ?>
                                        <?php if ($pago['MedioPago'] == 'Mercaderia') : ?>
                                            <li><?= Html::encode('Nro de Remito') ?>: <?= Html::encode($pago['NroRemito']) ?></li>
                                        <?php endif; ?>
                                        <?php if ($pago['MedioPago'] == 'Cheque') : ?>
                                            <li><?= Html::encode('Nro de Cheque') ?>: <?= Html::encode($pago['NroCheque']) ?></li>
                                        <?php endif; ?>
                                        </ul>
                                    </td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($pago['FechaAlta'])) ?></td>
                                    <td><?= Html::encode($pago['Observaciones']) ?></td>
                                    <td>
                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if (PermisosHelper::tienePermiso('PagarVenta')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['pagos/editar', 'id' => $pago['IdPago']]) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarPagoVenta')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['pagos/borrar', 'id' => $pago['IdPago']]) ?>"
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
            <div class="lineas--bottom">
                <div class="lineas--total">
                    Total de la Venta: <?= Html::encode($model['Monto']) ?>
                </div>
                <div class="lineas--total">
                    Total de los Pagos: <?= Html::encode($model['MontoPagado']) ?>
                </div>
            </div>
            <?php if ($model['Monto'] == $model['MontoPagado']) : ?>
            <div class="lineas--bottom">
                <div class="lineas--total">
                    PAGADO
                </div>
            </div>
            <?php endif; ?>
        </div>
        <?php else: ?>
            <p><strong>No hay pagos que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>