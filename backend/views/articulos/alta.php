<?php

use common\models\Articulos;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;

//$listas = array_diff($listas_completo,array(array_search('Por Defecto',$listas_completo)));

// foreach(array_keys($listas,array_search('Por Defecto',$listas,array_column($listas, 'IdListaPrecio'))) as $key ){
//     unset($listas[$key]);
// }

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
            
            <?= $form->field($model, 'IdProveedor')->dropDownList(ArrayHelper::map($proveedores, 'IdProveedor', 'Proveedor'), ['prompt' => 'Proveedor']) ?>

            <?= $form->field($model, 'Articulo') ?>

            <?= $form->field($model, 'Codigo') ?>

            <?= $form->field($model, 'Descripcion') ?>

            <?= $form->field($model, 'PrecioCosto') ?>

            <?= $form->field($model, 'PrecioVenta') ?>

            <?= $form->field($model, 'IdTipoGravamen')->dropDownList(ArrayHelper::map($gravamenes, 'IdTipoGravamen', 'TipoGravamen'), ['prompt' => 'Gravamen']) ?>

            <?php if (!isset($model['Articulo'])) : ?>
                <?= $form->field($model, 'PreciosVenta')->checkboxList(ArrayHelper::map($listas, 'IdListaPrecio', 'Lista')) ?>
            <?php endif; ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>