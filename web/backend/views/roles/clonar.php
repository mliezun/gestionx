<?php

use backend\models\Roles;
use yii\bootstrap\ActiveForm;
use yii\helpers\Html;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Roles */
?>
<div class="modal-dialog">
    <div class="modal-content">
        <div class="modal-header">
            <h5 class="modal-title"><?= Html::encode($titulo . ' ' . $model->Rol) ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'rol-form',]) ?>

        <div class="modal-body">

            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdRol') ?>

            <?= $form->field($model, 'Rol')->label('Nombre del nuevo rol') ?>

        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary', 'name' => 'rol-button']) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>
