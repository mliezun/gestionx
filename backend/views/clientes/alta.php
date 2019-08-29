<?php

use common\models\Clientes;
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

            <?php if ($model->Tipo == 'F'): ?>
                <?= $form->field($model, 'Nombres') ?>

                <?= $form->field($model, 'Apellidos') ?>
            <?php else: ?>
                <?= $form->field($model, 'RazonSocial') ?>
            <?php endif; ?>

            <?= $form->field($model, 'IdTipoDocAfip')->dropDownList(ArrayHelper::map($tiposdoc, 'IdTipoDocAfip', 'TipoDocAfip'), ['prompt' => 'Tipo de Documento']) ?>

            <?= $form->field($model, 'Documento') ?>

            <?= $form->field($model, 'Email') ?>

            <?= $form->field($model, 'Direccion') ?>

            <?= $form->field($model, 'Telefono') ?>

            <?= Html::activeHiddenInput($model, 'Tipo') ?>

            <?= $form->field($model, 'IdListaPrecio')->dropDownList(ArrayHelper::map($listas, 'IdListaPrecio', 'Lista'), ['prompt' => 'Lista']) ?>

            <?= $form->field($model, 'Observaciones')->textarea() ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>