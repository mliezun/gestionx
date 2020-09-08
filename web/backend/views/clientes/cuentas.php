<?php

use common\models\Clientes;
use common\helpers\PermisosHelper;
use common\helpers\FechaHelper;
use common\helpers\FormatoHelper;
use kartik\date\DatePicker;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\LinkPager;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Cuenta del Cliente: '. Clientes::Nombre($cliente);
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

            <?= $form->field($busqueda, 'FechaInicio')->widget(DatePicker::classname(), [
            'options' => ['placeholder' => 'Fecha desde'],
            'type' => DatePicker::TYPE_COMPONENT_PREPEND,
            'pluginOptions' => [
                'autoclose'=> true,
                'format' => 'dd/mm/yyyy'
            ]
            ]) ?>

            <?= $form->field($busqueda, 'FechaFin')->widget(DatePicker::classname(), [
                'options' => ['placeholder' => 'Fecha hasta'],
                'type' => DatePicker::TYPE_COMPONENT_PREPEND,
                'pluginOptions' => [
                    'autoclose'=> true,
                    'format' => 'dd/mm/yyyy',
                    'todayHighlight' => true,
                ]
            ]) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        <div class="alta--button">
            <button type="button" class="btn btn-primary"
                    data-modal="<?= Url::to(['/pagos/alta', 'id' => $cliente['IdCliente'], 'tipo' => 'C']) ?>"
                    data-hint="Nuevo Pago del Cliente">
                Nuevo Pago del Cliente
            </button>
        </div>

        <div id="errores"> </div>
        
        <div class="card">
            <div class="card-header">
                <h3 class="card-title"><?= Html::encode("Cliente") ?></h3>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Cliente</th>
                                <th>Documento</th>
                                <th>Datos</th>
                                <th>Tipo</th>
                                <th>Estado</th>
                                <th>$ Deuda</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><?= Html::encode(Clientes::Nombre($cliente)) ?></td>
                                <td><?= Html::encode($cliente['TipoDocAfip']) ?>: <?= Html::encode($cliente['Documento']) ?></td>
                                <td>
                                    <ul>
                                    <?php foreach (json_decode($cliente['Datos']) as $dato => $valor): ?>
                                        <?php if (isset($valor) && $valor != ''): ?>
                                            <li><?= Html::encode($dato) ?>: <?= Html::encode($valor) ?></li>
                                        <?php endif; ?>
                                    <?php endforeach; ?>
                                    </ul>
                                </td>
                                <td><?= Html::encode(Clientes::TIPOS[$cliente['Tipo']]) ?></td>
                                <td><?= Html::encode(Clientes::ESTADOS[$cliente['Estado']]) ?></td>
                                <?php
                                $deuda = $cliente['Deuda'] ?? 0;
                                $estilo = '';
                                if ($deuda > 0) {
                                    $estilo = ' style="color: red; font-weight: bold; font-size: 20px" ';
                                } elseif ($deuda < 0) {
                                    $estilo = ' style="color: green; font-weight: bold; font-size: 20px" ';
                                } else {
                                    $estilo = ' style="color: green; font-weight: bold" ';
                                }
                                echo "<td $estilo>";
                                echo Html::encode(FormatoHelper::formatearMonto($deuda));
                                echo '</td>';
                                ?>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <?php if (count($pagos) > 0): ?>
        <div class="card">
        <div class="card-header">
                    <h3 class="card-title"><?= Html::encode("Pagos del Cliente") ?></h3>
                </div>
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
                                            <li><?= Html::encode('Nro de Remito') ?>: <?= Html::encode($pago['NroRemito']) ?></li>
                                        <?php endif; ?>
                                        <?php if ($pago['MedioPago'] == 'Cheque') : ?>
                                            <li><?= Html::encode('Nro de Cheque') ?>: <?= Html::encode($pago['NroCheque']) ?></li>
                                        <?php endif; ?>
                                        <?php if ($pago['MedioPago'] == 'Retencion') : ?>
                                            <li><?= Html::encode('Tipo de Tributo') ?>: <?= Html::encode($tributos[json_decode($pago['Datos'])->IdTipoTributo]) ?></li>
                                        <?php endif; ?>
                                        </ul>
                                    </td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($pago['FechaAlta'])) ?></td>
                                    <td><?= Html::encode($pago['Observaciones']) ?></td>
                                    <td>
                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if (PermisosHelper::tienePermiso('PagarVenta')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['pagos/editar', 'id' => $pago['IdPago'], 'tipo' => 'C']) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarPagoVenta')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['pagos/borrar', 'id' => $pago['IdPago'], 'tipo' => 'C']) ?>"
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

        <?php if (count($models) > 0): ?>
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title"><?= Html::encode("Historial de Cuenta") ?></h3>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table">
                            <thead class="bg-light">
                                <tr class="border-0">
                                    <th>Fecha</th>
                                    <th>Tipo</th>
                                    <th>Descripcion</th>
                                    <th style="text-align: center">$ Monto</th>
                                    <th style="text-align: center">$ Deuda</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($models as $k=>$model): ?>
                                    <tr>
                                        <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['Fecha'])) ?></td>
                                        <td><?= Html::encode($model['Motivo']) ?></td>
                                        <td><?= Html::encode($model['Observaciones']) ?></td>
                                        <td style="text-align: center"><?= Html::encode(FormatoHelper::formatearMonto($model['Monto'])) ?></td>
                                        <td style="text-align: center"><?= Html::encode(FormatoHelper::formatearMonto($model['Deuda'])) ?></td>
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