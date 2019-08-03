<?php

use common\models\Usuarios;
use yii\bootstrap4\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Usuarios */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['Usuario']) ? 'Modificar usuario: ' . $model['Usuario'] : 'Alta Usuario') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'usuario-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdUsuario') ?>
            
            <?= $form->field($model, 'Nombres') ?>

            <?= $form->field($model, 'Apellidos') ?>

            <?php if (!isset($model['Usuario'])): ?>
                <?= $form->field($model, 'Usuario') ?>
            <?php endif; ?>

            <?= $form->field($model, 'Email') ?>

            <?= $form->field($model, 'IdRol')->dropDownList(ArrayHelper::map($roles, 'IdRol', 'Rol'), ['prompt' => 'Rol']) ?>

            <?= $form->field($model, 'Observaciones')->textarea() ?>
            
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>