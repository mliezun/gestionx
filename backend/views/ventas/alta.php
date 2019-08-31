<?php

use common\models\Ventas;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Ventas */
/* @var $comprobantes TiposComprobantesAfip */
/* @var $tributos TiposTributos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['IdVenta']) ? 'Modificar venta: ' . $model['IdVenta'] : 'Nueva venta') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'ventas-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdVenta') ?>
            
            <?= $form->field($model, 'IdCliente')->dropDownList($clientes, ['prompt' => 'Cliente']) ?>

            <?= $form->field($model, 'IdTipoComprobanteAfip')->dropDownList(ArrayHelper::map($comprobantes, 'IdTipoComprobanteAfip', 'TipoComprobanteAfip'), ['prompt' => 'Tipo de Comprobante']) ?>

            <?= $form->field($model, 'IdTipoTributo')->dropDownList(ArrayHelper::map($tributos, 'IdTipoTributo', 'TipoTributo'), ['prompt' => 'Tipo de Tributo']) ?>

            <?php if (!isset($model['IdVenta'])): ?>
                <?= $form->field($model, 'Tipo')->dropDownList(Ventas::TIPOS_ALTA, ['prompt' => 'Tipo']) ?>
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