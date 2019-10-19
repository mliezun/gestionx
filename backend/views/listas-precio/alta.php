<?php

use common\models\ListasPrecio;
use yii\bootstrap4\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model ListasPrecio */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= $titulo ?>: <?= $model['Lista'] ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'usuario-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdListaPrecio') ?>
            
            <?= $form->field($model, 'Lista') ?>

            <?= $form->field($model, 'Porcentaje', [
                'template' => '{beginLabel}{labelTitle}{endLabel}<div class="input-group"><div class="input-group-prepend"><span class="input-group-text" style="max-height: 35px;">%</span></div>{input}</div>{error}{hint}'
            ]) ?>
            
            <?= $form->field($model, 'Observaciones') ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>