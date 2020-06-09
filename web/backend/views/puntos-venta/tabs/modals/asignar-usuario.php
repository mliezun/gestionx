<?php

use yii\bootstrap4\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\web\View;
use kartik\select2\Select2;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model PuntosVenta */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title">Asignar Usuario</h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'usuario-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= $form->field($model, 'IdUsuario')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($usuarios, 'IdUsuario', 'Usuario'),
                'language' => 'es',
                'options' => ['placeholder' => 'Usuario'],
                'pluginOptions' => [
                    'allowClear' => true
                ],
            ]) ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>