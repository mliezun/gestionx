<?php

use common\models\Articulos;
use common\models\GestorTiposGravamenes;
use common\models\GestorProveedores;
use common\models\GestorListasPrecio;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;

$listas = (new GestorListasPrecio)->Buscar();

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Articulos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= ($titulo) ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'articulo-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdArticulo') ?>

            <?= Html::activeHiddenInput($model, 'IdEmpresa') ?>

            <?= Html::activeHiddenInput($model, 'IdProveedor') ?>

            <?= Html::activeHiddenInput($model, 'Articulo') ?>

            <?= Html::activeHiddenInput($model, 'Codigo') ?>

            <?= Html::activeHiddenInput($model, 'Descripcion') ?>

            <?= Html::activeHiddenInput($model, 'PrecioCosto') ?>

            <?= Html::activeHiddenInput($model, 'PrecioVenta') ?>

            <?= Html::activeHiddenInput($model, 'Gravamenes') ?>

            <?php foreach (json_decode($model['PreciosVenta']) as $nombre => $valor): ?>
                <?= Html::encode($nombre) ?>: <?= Html::encode($valor) ?>
            <?php endforeach; ?>

            <?= $form->field($model, 'PreciosVenta')->checkboxList(ArrayHelper::map($listas, 'IdListaPrecio', 'Lista')) ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>