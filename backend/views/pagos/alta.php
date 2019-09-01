<?php

use common\models\Pagos;
use yii\helpers\ArrayHelper;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Pagos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['IdPago']) ? 'Modificar Pago ' . $model['MedioPago'] : 'Nuevo Pago ' . $model['MedioPago']) ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'pago-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdVenta') ?>

            <?= Html::activeHiddenInput($model, 'IdMedioPago') ?>

            <?php if ($model['MedioPago'] == 'Tarjeta') :?>
                <?= $form->field($model, 'NroTarjeta') ?>

                <?= $form->field($model, 'MesVencimiento') ?>

                <?= $form->field($model, 'AnioVencimiento') ?>

                <?= $form->field($model, 'CCV') ?>
                
            <?php endif; ?>

            <?php if ($model['MedioPago'] == 'Mercaderia') :?>
                <?= $form->field($model, 'IdRemito')->dropDownList(ArrayHelper::map($remitos, 'IdRemito', 'NroRemito'), ['prompt' => 'Remito']) ?>
                
            <?php endif; ?>

            <?php if ($model['MedioPago'] == 'Cheque') :?>
                <?= $form->field($model, 'IdCheque')->dropDownList(ArrayHelper::map($cheques, 'IdCheque', 'NroCheque'), ['prompt' => 'Cheque']) ?>
                
            <?php endif; ?>

            <?php if ($model['MedioPago'] == 'Tarjeta' OR $model['MedioPago'] == 'Efectivo' ) :?>

                <?= $form->field($model, 'Monto') ?>

            <?php endif; ?>

            <?= $form->field($model, 'Observaciones') ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>