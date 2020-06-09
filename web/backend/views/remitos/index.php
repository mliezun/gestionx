<?php

use common\models\Remitos;
use common\models\PuntosVenta;
use common\models\Proveedores;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Punto de Venta: '.$puntoventa->PuntoVenta.' - Remitos';
$this->params['breadcrumbs'][] = $this->title;

$proveedor = new Proveedores();
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline']); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(ArrayHelper::map($proveedores, 'IdProveedor', 'Proveedor'), ['prompt' => 'Proveedor']) ?>

            <?= $form->field($busqueda, 'Combo2')->dropDownList(Remitos::ESTADOS, ['prompt' => 'Estado']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        <?php if (PermisosHelper::tienePermiso('AltaRemito')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/remitos/alta','id' => $puntoventa['IdPuntoVenta']]) ?>"
                        data-hint="Nuevo Remito">
                    Nuevo Remito
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
                                <th>Nro de Remito</th>
                                <th>Nro de Factura</th>
                                <th>Proveedor</th>
                                <th>Fecha de Alta</th>
                                <th>Fecha de Facturacion</th>
                                <th>Estado</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <?php $proveedor->IdProveedor=$model['IdProveedor'];
                                    $proveedor->Dame(); ?>
                                    <td><?= Html::encode($model['NroRemito']) ?></td>
                                    <td><?= Html::encode($model['NroFactura']) ?></td>
                                    <td><?= Html::encode($proveedor->Proveedor) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAlta'])) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaFacturado'])) ?></td>
                                    <td><?= Html::encode(Remitos::ESTADOS[$model['Estado']]) ?></td>
                                    <td><?= Html::encode($model['Observaciones']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if ($model['Estado'] == 'E') :?>
                                                <?php if (PermisosHelper::tienePermiso('AltaLineaExistencia')) : ?>
                                                    <a class="btn btn-default"
                                                            href="<?= Url::to(['/ingresos/lineas', 'id' => $model['IdIngreso']]) ?>" 
                                                            data-hint="Lineas">
                                                        <i class="fas fa-clipboard-list"></i>
                                                    </a>
                                                <?php endif; ?>
                                                <?php if (PermisosHelper::tienePermiso('ModificarRemito')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-modal="<?= Url::to(['remitos/editar', 'id' => $model['IdRemito']]) ?>"
                                                            data-hint="Modificar">
                                                        <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if ($model['Estado'] == 'E' OR $model['Estado'] == 'A') : ?>
                                                <?php if ($model['Estado'] == 'E') :?>
                                                    <?php if (PermisosHelper::tienePermiso('ActivarRemito')): ?>
                                                        <button type="button" class="btn btn-default"
                                                                data-ajax="<?= Url::to(['remitos/activar', 'id' => $model['IdRemito']]) ?>"
                                                                data-hint="Activar">
                                                            <i class="fa fa-check-circle" style="color: green"></i>
                                                        </button>
                                                    <?php endif; ?>
                                                <?php endif; ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaRemito')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['remitos/dar-baja', 'id' => $model['IdRemito']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarRemito')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['remitos/borrar', 'id' => $model['IdRemito']]) ?>"
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
        <?php else: ?>
            <p><strong>No hay remitos que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>