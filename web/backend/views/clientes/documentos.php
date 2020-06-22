<?php

use common\models\Clientes;
use common\models\Provincias;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;
use yii\helpers\ArrayHelper;
use kartik\select2\Select2;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Clientes */

?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['IdCliente']) ? 'Modificar Cliente: ' . Clientes::Nombre($model) : 'Nuevo Cliente') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'cliente-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdCliente') ?>

            <?= Html::activeHiddenInput($model, 'IdEmpresa') ?>

            <?php foreach ($tiposdoc as $tipodoc): ?>
                <?php if ($tipodoc['IdTipoDocAfip'] == $model->IdTipoDocAfip): ?>
                    <?= $form->field($model, 'Documento')->textInput()->label($tipodoc['TipoDocAfip']) ?>
                <?php else: ?>
                    <?= $form->field($model, $tipodoc['TipoDocAfip']) ?>
                <?php endif; ?>
            <?php endforeach; ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>
