<?php

use common\models\Pagos;
use yii\helpers\ArrayHelper;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;
use kartik\select2\Select2;
use kartik\money\MaskMoney;

// MOVER A OTRO ARCHIVO
$this->registerJs('
(function() {
    function controlarTipoPago() {
        var cambio = false;
        switch (parseInt($("#pagos-idmediopago").val())) {
            // Efectivo - Deposito
            case 1:
            case 6:
                $(".field-pagos-monto").show();

                $("#pagos-nrotarjeta").val("");
                $(".field-pagos-nrotarjeta").hide();
                $("#pagos-mesvencimiento").val("");
                $(".field-pagos-mesvencimiento").hide();
                $("#pagos-aniovencimiento").val("");
                $(".field-pagos-aniovencimiento").hide();
                $("#pagos-ccv").val("");
                $(".field-pagos-ccv").hide();
                $("#pagos-idremito").val(0);
                $(".field-pagos-idremito").hide();
                $("#pagos-idcheque").val(0);
                $(".field-pagos-idcheque").hide();
                $("#pagos-idtipotributo").val(0);
                $(".field-pagos-idtipotributo").hide();
                return true;
            // Mercaderia
            case 2:
                $(".field-pagos-idremito").show();

                $("#pagos-monto").val(0);
                $(".field-pagos-monto").hide();
                $("#pagos-nrotarjeta").val("");
                $(".field-pagos-nrotarjeta").hide();
                $("#pagos-mesvencimiento").val("");
                $(".field-pagos-mesvencimiento").hide();
                $("#pagos-aniovencimiento").val("");
                $(".field-pagos-aniovencimiento").hide();
                $("#pagos-ccv").val("");
                $(".field-pagos-ccv").hide();
                $("#pagos-idcheque").val(0);
                $(".field-pagos-idcheque").hide();
                $("#pagos-idtipotributo").val(0);
                $(".field-pagos-idtipotributo").hide();
                return true;
            // Tarjeta
            case 3:
                $(".field-pagos-monto").show();
                $(".field-pagos-nrotarjeta").show();
                $(".field-pagos-mesvencimiento").show();
                $(".field-pagos-aniovencimiento").show();
                $(".field-pagos-ccv").show();
                
                $("#pagos-idremito").val(0);
                $(".field-pagos-idremito").hide();
                $("#pagos-idcheque").val(0);
                $(".field-pagos-idcheque").hide();
                $("#pagos-agente").val("");
                $(".field-pagos-agente").hide();
                $("#pagos-idtipoiva").val(0);
                $(".field-pagos-idtipoiva").hide();
                return true;
            // Cheque
            case 5:
                $(".field-pagos-idcheque").show();

                $("#pagos-monto").val(0);
                $(".field-pagos-monto").hide();
                $("#pagos-nrotarjeta").val("");
                $(".field-pagos-nrotarjeta").hide();
                $("#pagos-mesvencimiento").val("");
                $(".field-pagos-mesvencimiento").hide();
                $("#pagos-aniovencimiento").val("");
                $(".field-pagos-aniovencimiento").hide();
                $("#pagos-ccv").val("");
                $(".field-pagos-ccv").hide();
                $("#pagos-idremito").val(0);
                $(".field-pagos-idremito").hide();
                $("#pagos-idtipotributo").val(0);
                $(".field-pagos-idtipotributo").hide();
                return true;
            // Retencion
            case 7:
                $(".field-pagos-monto").show();
                $(".field-pagos-idtipotributo").show();

                $("#pagos-nrotarjeta").val("");
                $(".field-pagos-nrotarjeta").hide();
                $("#pagos-mesvencimiento").val("");
                $(".field-pagos-mesvencimiento").hide();
                $("#pagos-aniovencimiento").val("");
                $(".field-pagos-aniovencimiento").hide();
                $("#pagos-ccv").val("");
                $(".field-pagos-ccv").hide();
                $("#pagos-idremito").val(0);
                $(".field-pagos-idremito").hide();
                $("#pagos-idcheque").val(0);
                $(".field-pagos-idcheque").hide();
                return true;
            default:
                break;
        }
        // Efectivo - Deposito
        $("#pagos-monto").val(0);
        $(".field-pagos-monto").hide();

        // Tarjeta
        $("#pagos-nrotarjeta").val("");
        $(".field-pagos-nrotarjeta").hide();
        $("#pagos-mesvencimiento").val("");
        $(".field-pagos-mesvencimiento").hide();
        $("#pagos-aniovencimiento").val("");
        $(".field-pagos-aniovencimiento").hide();
        $("#pagos-ccv").val("");
        $(".field-pagos-ccv").hide();

        // Mercaderia
        $("#pagos-idremito").val(0);
        $(".field-pagos-idremito").hide();

        // Cheque
        $("#pagos-idcheque").val(0);
        $(".field-pagos-idcheque").hide();

        // Retencion
        $("#pagos-idtipotributo").val(0);
        $(".field-pagos-idtipotributo").hide();
        return false;
    };

    $("#pagos-idmediopago").change(function() {
        controlarTipoPago();
        $("#w0").yiiActiveForm("validateAttribute", "pagos-monto");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-nrotarjeta");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-mesvencimiento");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-aniovencimiento");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-ccv");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idremito");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idcheque");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idtipotributo");
    });

    $("#pagos-idmediopago").keyup(function() {
        controlarTipoPago();
        $("#w0").yiiActiveForm("validateAttribute", "pagos-monto");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-nrotarjeta");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-mesvencimiento");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-aniovencimiento");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-ccv");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idremito");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idcheque");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idtipotributo");
    });

    controlarTipoPago();
})();
');

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

            <?php if (!isset($model['IdPago'])) : ?>
                <?= $form->field($model, 'IdMedioPago')->dropDownList(ArrayHelper::map($medios, 'IdMedioPago', 'MedioPago'), ['prompt' => 'Medio de Pago']) ?>

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