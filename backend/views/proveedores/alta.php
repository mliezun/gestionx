<?php

use common\models\Proveedores;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Proveedores */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['Proveedor']) ? 'Modificar proveedor: ' . $model['Proveedor'] : 'Nuevo proveedor') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'proveedor-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdProveedor') ?>

            <?php if (isset($tipo) && $tipo === 'aumento'): ?>
                <?= $form->field($model, 'Aumento', [
                    'template' => '{beginLabel}{labelTitle}{endLabel}<div class="input-group"><div class="input-group-prepend"><span class="input-group-text" style="max-height: 35px;">%</span></div>{input}</div>{error}{hint}'
                ]) ?>
            <?php elseif (isset($tipo) && $tipo === 'carga'): ?>
                <p>
                    Debe subir un fichero en formato csv (sin cabecera), que use comas ',' como delimitadores de columna
                    y saltos de línea como delimitadores de filas. Para desambiguación de cadenas debe usar
                    comillas dobles ".
                </p>
                <p>
                    Las columnas deben estar dispuestas de la siguiente manera:
                    <br><strong>Articulo | Codigo | Descripcion | PrecioCosto | IVA</strong>
                </p>
                <p>
                    <?= $form->field($model, 'Archivo')->fileInput() ?>
                </p>
            <?php else: ?>
                <?= Html::activeHiddenInput($model, 'IdEmpresa') ?>
                <?= $form->field($model, 'Proveedor') ?>
                <?= $form->field($model, 'Descuento', [
                    'template' => '{beginLabel}{labelTitle}{endLabel}<div class="input-group"><div class="input-group-prepend"><span class="input-group-text" style="max-height: 35px;">%</span></div>{input}</div>{error}{hint}'
                ]) ?>
            <?php endif; ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>