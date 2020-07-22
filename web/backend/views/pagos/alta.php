<?php

use common\models\Pagos;
use yii\helpers\ArrayHelper;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;
use kartik\select2\Select2;
use kartik\money\MaskMoney;
use backend\assets\PagosAsset;

PagosAsset::register($this);

$this->registerJs("Pagos.init();");

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

        <?php $form = ActiveForm::begin(['id' => 'pagos-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdPago') ?>

            <?= Html::activeHiddenInput($model, 'IdVenta') ?>

            <?= Html::activeHiddenInput($model, 'MontoVenta') ?>

            <?php if (!isset($model['IdPago'])) : ?>
                <?= $form->field($model, 'IdMedioPago')->dropDownList(ArrayHelper::map($medios, 'IdMedioPago', 'MedioPago'), ['prompt' => 'Medio de Pago']) ?>
            <?php else : ?>
                <?= Html::activeHiddenInput($model, 'IdMedioPago') ?>
            <?php endif; ?>

            <?= $form->field($model, 'NroTarjeta') ?>

            <?= $form->field($model, 'MesVencimiento') ?>

            <?= $form->field($model, 'AnioVencimiento') ?>

            <?= $form->field($model, 'CCV') ?>

            <?= $form->field($model, 'IdRemito')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($remitos, 'IdRemito', 'NroRemito'),
                'language' => 'es',
                'options' => ['placeholder' => 'Nro de Remito'],
                'pluginOptions' => [
                    'allowClear' => true
                ]
            ]) ?>

            <?= $form->field($model, 'IdCheque')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($cheques, 'IdCheque', 'NroCheque'),
                'language' => 'es',
                'options' => ['placeholder' => 'Nro de Cheque'],
                'pluginOptions' => [
                    'allowClear' => true
                ]
            ]) ?>

            <?php // $form->field($model, 'Monto')->widget(MaskMoney::classname()) 
            ?>

            <?= $form->field($model, 'Descuento', [
                'template' => '{beginLabel}{labelTitle}{endLabel}<div class="input-group"><div class="input-group-prepend"><span class="input-group-text" style="max-height: 35px;">%</span></div>{input}</div>{error}{hint}'
            ]) ?>

            <?= $form->field($model, 'Monto') ?>

            <?= $form->field($model, 'IdTipoTributo')->dropDownList(ArrayHelper::map($tributos, 'IdTipoTributo', 'TipoTributo')) ?>

            <?= $form->field($model, 'Observaciones')->textarea() ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>