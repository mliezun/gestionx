<?php

use common\models\Clientes;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;
use yii\helpers\ArrayHelper;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Clientes */
$tipos=Clientes::TIPOS;
$array=ArrayHelper::remove($tipos,'T');
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['Cliente']) ? 'Modificar Cliente: ' . $model['Cliente'] : 'Nuevo Cliente') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'cliente-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdCliente') ?>

            <?= Html::activeHiddenInput($model, 'IdEmpresa') ?>
            
            <?= $form->field($model, 'Nombres') ?>

            <?= $form->field($model, 'Apellidos') ?>

            <?= $form->field($model, 'RazonSocial') ?>

            <?= $form->field($model, 'Datos') ?>

            <?= $form->field($model, 'Tipo')->dropDownList($tipos, ['prompt' => 'Tipo']) ?>

            <?= $form->field($model, 'Observaciones') ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>