<?php

use common\models\Ventas;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;
use kartik\select2\Select2;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Ventas */
/* @var $comprobantes TiposComprobantesAfip */
/* @var $tributos TiposTributos */

$this->registerJs('
(function() {
    function controlarTipoVenta() {
        if ($("#ventas-tipo").val() === "V") {
            $(".field-ventas-idtipocomprobanteafip").show();
            return true;
        }
        $("#ventas-idtipocomprobanteafip").val(0);
        $(".field-ventas-idtipocomprobanteafip").hide();
        return false;
    };

    $("#ventas-tipo").change(function() {
        controlarTipoVenta();
        $("#w0").yiiActiveForm("validateAttribute", "ventas-idtipocomprobanteafip");
    });

    $("#ventas-tipo").keyup(function() {
        controlarTipoVenta();
        $("#w0").yiiActiveForm("validateAttribute", "ventas-idtipocomprobanteafip");
    });

    controlarTipoVenta();
})();
');

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
            
            <?= $form->field($model, 'IdCliente')->widget(Select2::classname(), [
                'data' => $clientes,
                'language' => 'es',
                'options' => ['placeholder' => 'Cliente'],
                'pluginOptions' => [
                    'allowClear' => true
                ],
            ]) ?>

            <?php if (!isset($model['IdVenta'])): ?>
                <?= $form->field($model, 'Tipo')->dropDownList(Ventas::TIPOS_ALTA, ['prompt' => 'Tipo']) ?>

                <?= $form->field($model, 'IdTipoComprobanteAfip')->dropDownList(ArrayHelper::map($comprobantes, 'IdTipoComprobanteAfip', 'TipoComprobanteAfip'), ['prompt' => 'Tipo de Comprobante']) ?>
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