<?php

use common\models\Cheques;
use common\models\Clientes;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;
use kartik\select2\Select2;
use kartik\money\MaskMoney;
use kartik\date\DatePicker;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Cheques */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['NroCheque']) ? 'Modificar cheque: ' . $model['NroCheque'] : 'Nuevo cheque') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'cheque-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdCheque') ?>

            <?= $form->field($model, 'NroCheque') ?>

            <?= $form->field($model, 'IdBanco')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($bancos, 'IdBanco', 'Banco'),
                'language' => 'es',
                'options' => ['placeholder' => 'Banco'],
                'pluginOptions' => [
                    'allowClear' => true
                ],
            ]) ?>

            <?php if (isset($model->IdCliente) || (isset($Tipo) && $Tipo == 'Cliente')) {
                echo $form->field($model, 'IdCliente')->widget(Select2::classname(), [
                    'data' => $clientes,
                    'language' => 'es',
                    'options' => ['placeholder' => 'Cliente'],
                    'pluginOptions' => [
                        'allowClear' => true
                    ],
                ]);
            }
            ?>

            <?= $form->field($model, 'IdDestinoCheque')->widget(Select2::classname(), [
                    'data' => ArrayHelper::map($destinos, 'IdDestinoCheque', 'Destino'),
                    'language' => 'es',
                    'options' => ['placeholder' => 'Destino'],
                    'pluginOptions' => [
                        'allowClear' => true
                    ],
                ]);
            ?>

            <?php // $form->field($model, 'Importe')->widget(MaskMoney::classname()) ?>

            <?= $form->field($model, 'Importe') ?>

            <?= $form->field($model, 'FechaVencimiento')->widget(DatePicker::classname(), [
                'options' => ['placeholder' => 'Fecha de Vencimiento'],
                'type' => DatePicker::TYPE_INPUT,
                'pluginOptions' => [
                    'autoclose'=> true,
                    'format' => 'dd/mm/yyyy'
                ]
            ]) ?>


            <?= $form->field($model, 'Obversaciones')->textarea() ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>