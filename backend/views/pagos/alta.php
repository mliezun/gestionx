<?php

use common\models\Pagos;
use common\models\GestorCheques;
use common\models\GestorMediosPago;
use common\models\GestorRemitos;
use common\models\GestorTiposComprobantes;
use yii\helpers\ArrayHelper;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;

$mediospago = (new GestorMediosPago())->Listar();
$tiposcomprobantes = (new GestorTiposComprobantes())->Listar();
$cheques = (new GestorCheques())->Buscar();


/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Pagos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= 'Nuevo pago venta' ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'pago-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdVenta') ?>

            <?= Html::activeHiddenInput($model, 'IdMedioPago') ?>

            <?= $form->field($model, 'IdTipoComprobante')->dropDownList(ArrayHelper::map($tiposcomprobantes, 'IdTipoComprobante', 'TipoComprobante'), ['prompt' => 'Tipo de Comprobante']) ?>

            <?php if ($model['IdMedioPago'] == '3') :?>
                <?= $form->field($model, 'NroTarjeta') ?>

                <?= $form->field($model, 'MesVencimiento') ?>

                <?= $form->field($model, 'AnioVencimiento') ?>

                <?= $form->field($model, 'CCV') ?>
                
            <?php endif; ?>

            <?php if ($model['IdMedioPago'] == '2') :?>
                <?= $form->field($model, 'IdRemito')->dropDownList(ArrayHelper::map($remitos, 'IdRemito', 'NroRemito'), ['prompt' => 'Remito']) ?>
                
            <?php endif; ?>

            <?php if ($model['IdMedioPago'] == '5') :?>
                <?= $form->field($model, 'IdCheque')->dropDownList(ArrayHelper::map($cheques, 'IdCheque', 'Cheque'), ['prompt' => 'Cheque']) ?>
                
            <?php endif; ?>

            <?php if ($model['IdMedioPago'] == '1' OR $model['IdMedioPago'] == '2' OR $model['IdMedioPago'] == '3' ) :?>

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