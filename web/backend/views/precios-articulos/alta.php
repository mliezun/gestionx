<?php

use common\models\PreciosArticulos;
use yii\helpers\ArrayHelper;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;
use kartik\select2\Select2;
use kartik\money\MaskMoney;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model PreciosArticulos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['IdListaPrecio']) ? 'Modificar Precio de la Lista ' . $model['Lista'] : 'Nuevo Precio ') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'precio-articulo-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdArticulo') ?>

            <?php if (!isset($model['IdListaPrecio'])) :?>
                <?= $form->field($model, 'IdListaPrecio')->widget(Select2::classname(), [
                    'data' => ArrayHelper::map($listas, 'IdListaPrecio', 'Lista'),
                    'language' => 'es',
                    'options' => ['placeholder' => 'Lista'],
                    'pluginOptions' => [
                        'allowClear' => true
                    ]
                ]) ?>
                
            <?php endif; ?>

            <?= $form->field($model, 'PrecioVenta')->widget(MaskMoney::classname()) ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>