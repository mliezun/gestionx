<?php

use common\models\Cheques;
use common\models\GestorCheques;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Cheques';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline', 'method' => 'GET']); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'FechaInicio') ?>

            <?= $form->field($busqueda, 'FechaFin') ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(Cheques::ESTADOS, ['prompt' => 'Proveedor']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        
        <div class="alta--button">
            <?php if (PermisosHelper::tienePermiso('AltaChequeCliente')) : ?>
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/cheques/alta', 'Tipo' => 'Cliente']) ?>"
                        data-hint="Nuevo Cheque Cliente">
                    Nuevo Cheque (Cliente)
                </button>
            <?php endif; ?>
            <?php if (PermisosHelper::tienePermiso('AltaChequePropio')) : ?>
                <button type="button" class="btn btn-secondary"
                        data-modal="<?= Url::to(['/cheques/alta', 'Tipo' => 'Propio']) ?>"
                        data-hint="Nuevo Cheque Propio">
                    Nuevo Cheque (Propio)
                </button>
            <?php endif; ?>
        </div>
        <div id="errores"> </div>
        
        <?php if (count($models) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Descripcion</th>
                                <th>Banco</th>
                                <th>NroCheque</th>
                                <th>Importe</th>
                                <th>FechaAlta</th>
                                <th>FechaVencimiento</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $k=>$model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Descripcion']) ?></td>
                                    <td><?= Html::encode($model['Banco']) ?></td>
                                    <td><?= Html::encode($model['NroCheque']) ?></td>
                                    <td><?= Html::encode($model['Importe']) ?></td>
                                    <td><?= Html::encode($model['FechaAlta']) ?></td>
                                    <td><?= Html::encode($model['FechaVencimiento']) ?></td>
                                    <td><?= Html::encode(Cheques::ESTADOS[$model['Estado']]) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                            
                                            <?php if (PermisosHelper::tienePermiso('ModificarCheque')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['cheques/editar', 'id' => $model['IdCheque']]) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if ($model['Estado'] == 'B') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarCheque')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['cheques/activar', 'id' => $model['IdCheque']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaCheque')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['cheques/dar-baja', 'id' => $model['IdCheque']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarCheque')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['cheques/borrar', 'id' => $model['IdCheque']]) ?>"
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
            <p><strong>No hay cheques que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>