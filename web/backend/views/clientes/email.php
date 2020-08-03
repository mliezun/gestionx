<?php

use common\models\Clientes;
use common\models\Provincias;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;
use yii\helpers\ArrayHelper;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Clientes */

?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= ('Agregar email al Cliente') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'cliente-email-form',]) ?>

            <div class="modal-body">
                <div id="errores-modal"> </div>

                <?= Html::activeHiddenInput($model, 'IdCliente') ?>

                <?= Html::activeHiddenInput($model, 'IdEmpresa') ?>

                <?= $form->field($model, 'Email') ?>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
                <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
            </div>

        <?php ActiveForm::end(); ?>
    </div>
</div>