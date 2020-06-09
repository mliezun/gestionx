<?php

use common\models\Pagos;
use common\models\GestorMediosPago;
use yii\helpers\ArrayHelper;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;

$mediospago = (new GestorMediosPago())->Listar();


/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Pagos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= 'Elegir medio de pago' ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'pago-eleccion-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdVenta') ?>

            <?= $form->field($model, 'IdMedioPago')->dropDownList(ArrayHelper::map($mediospago, 'IdMedioPago', 'MedioPago'), ['prompt' => 'Medio de Pago']) ?>

            <?= $form->field($model, 'FechaDebe')->checkbox(array('label'=>'Pago Parcial')) ?>

        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Siguiente', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>