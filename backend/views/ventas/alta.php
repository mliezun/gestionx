<?php

use common\models\Ventas;
use common\models\GestorClientes;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;

$clientes = (new GestorClientes())->Listar();

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Remitos */
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

            <?= $form->field($model, 'Tipo')->dropDownList(Ventas::TIPOS_ALTA, ['prompt' => 'Tipo']) ?>

            <?= $form->field($model, 'Observaciones') ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>