<?php

use common\models\Articulos;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;
use kartik\select2\Select2;
use kartik\money\MaskMoney;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Articulos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['Articulo']) ? 'Modificar artículo: ' . $model['Articulo'] : 'Nuevo artículo') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'articulo-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdArticulo') ?>

            <?= Html::activeHiddenInput($model, 'IdEmpresa') ?>
            
            <?php if (!isset($model['Articulo'])): ?>
                <?= $form->field($model, 'IdProveedor')->widget(Select2::classname(), [
                    'data' => ArrayHelper::map($proveedores, 'IdProveedor', 'Proveedor'),
                    'language' => 'es',
                    'options' => ['placeholder' => 'Proveedor'],
                    'pluginOptions' => [
                        'allowClear' => true
                    ],
                ]) ?>
            <?php endif; ?>

            <?= $form->field($model, 'Articulo') ?>

            <?= $form->field($model, 'Codigo') ?>

            <?= $form->field($model, 'Descripcion') ?>

            <?php // $form->field($model, 'PrecioCosto')->widget(MaskMoney::classname())?>

            <?= $form->field($model, 'PrecioCosto') ?>

            <?= $form->field($model, 'IdTipoIVA')->dropDownList(ArrayHelper::map($ivas, 'IdTipoIVA', 'TipoIVA'), ['prompt' => 'IVA']) ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>