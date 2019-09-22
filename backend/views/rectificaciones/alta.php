<?php

use common\models\RectificacionesPV;
use yii\helpers\ArrayHelper;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;
use kartik\select2\Select2;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model RectificacionesPV */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= ('Nueva Rectificación') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'pago-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdRectificacionPV') ?>

            <?= $form->field($model, 'IdArticulo')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($articulos, 'IdArticulo', 'Articulo'),
                'language' => 'es',
                'options' => ['placeholder' => 'Articulo'],
                'pluginOptions' => [
                    'allowClear' => true
                ],
            ]) ?>

            <?= $form->field($model, 'IdPuntoVentaDestino')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($puntosventa, 'IdPuntoVenta', 'PuntoVenta'),
                'language' => 'es',
                'options' => ['placeholder' => 'Punto de venta Destino'],
                'pluginOptions' => [
                    'allowClear' => true
                ],
            ]) ?>

            <?= $form->field($model, 'Cantidad') ?>

            <?= $form->field($model, 'Observaciones') ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>