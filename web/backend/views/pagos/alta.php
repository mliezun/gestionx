<?php

use common\models\Pagos;
use yii\helpers\ArrayHelper;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;
use kartik\select2\Select2;
use kartik\money\MaskMoney;

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
                <?= $form->field($model, 'IdRemito')->widget(Select2::classname(), [
                    'data' => ArrayHelper::map($remitos, 'IdRemito', 'NroRemito'),
                    'language' => 'es',
                    'options' => ['placeholder' => 'Nro de Remito'],
                    'pluginOptions' => [
                        'allowClear' => true
                    ]
                ]) ?>
                
            <?php endif; ?>

            <?php if ($model['MedioPago'] == 'Cheque') :?>
                <?= $form->field($model, 'IdCheque')->widget(Select2::classname(), [
                    'data' => ArrayHelper::map($cheques, 'IdCheque', 'NroCheque'),
                    'language' => 'es',
                    'options' => ['placeholder' => 'Nro de Cheque'],
                    'pluginOptions' => [
                        'allowClear' => true
                    ]
                ]) ?>
                
            <?php endif; ?>

            <?php if ($model['MedioPago'] == 'Tarjeta' OR $model['MedioPago'] == 'Efectivo' ) :?>

                <?php // $form->field($model, 'Monto')->widget(MaskMoney::classname()) ?>

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