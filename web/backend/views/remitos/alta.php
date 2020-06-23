<?php

use common\models\Articulos;
use common\models\GestorProveedores;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;
use kartik\select2\Select2;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Remitos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['Remito']) ? 'Modificar remito: ' . $model['Remito'] : 'Nuevo remito') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'articulo-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdRemito') ?>

            <?= Html::activeHiddenInput($model, 'IdEmpresa') ?>
            
            <?= $form->field($model, 'IdProveedor')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($proveedores, 'IdProveedor', 'Proveedor'),
                'language' => 'es',
                'options' => ['placeholder' => 'Proveedor'],
                'pluginOptions' => [
                    'allowClear' => true
                ],
            ]) ?>
            
            <?php if (Yii::$app->session->get('Parametros')['CANTCANALES'] > 1) : ?>
                <?= $form->field($model, 'IdCanal')->widget(Select2::classname(), [
                    'data' => ArrayHelper::map($canales, 'IdCanal', 'Canal'),
                    'language' => 'es',
                    'options' => ['placeholder' => 'Canal'],
                    'pluginOptions' => [
                        'allowClear' => true
                    ],
                ]) ?>
            <?php endif; ?>

            <?= $form->field($model, 'NroRemito') ?>

            <?= $form->field($model, 'CAI') ?>

            <?= $form->field($model, 'Observaciones')->textArea() ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>