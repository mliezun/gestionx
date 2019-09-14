<?php

use common\models\Cheques;
use common\models\GestorBancos;
use common\models\GestorClientes;
use common\models\Clientes;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\web\View;
/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Cheques */

$gestorBancos = new GestorBancos;
$bancos = $gestorBancos->Buscar();

$gestorClientes = new GestorClientes;
$clientes = array();
foreach ($gestorClientes->Buscar() as $cliente) {
    $clientes[$cliente['IdCliente']] = Clientes::Nombre($cliente);
}
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= (isset($model['NroCheque']) ? 'Modificar cheque: ' . $model['NroCheque'] : 'Nuevo cheque') ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <?php $form = ActiveForm::begin(['id' => 'cheque-form',]) ?>

        <div class="modal-body">
            <div id="errores-modal"> </div>

            <?= Html::activeHiddenInput($model, 'IdCheque') ?>

            <?= $form->field($model, 'NroCheque') ?>

            <?= $form->field($model, 'IdBanco')->dropDownList(ArrayHelper::map($bancos, 'IdBanco', 'Banco'), ['prompt' => 'Banco']) ?>

            <?php if (isset($model->IdCliente)) {
                echo $form->field($model, 'IdCliente')->dropDownList($clientes, ['prompt' => 'Cliente']);
            }
            ?>

            <?= $form->field($model, 'Importe') ?>

            <?= $form->field($model, 'FechaVencimiento') ?>

            <?= $form->field($model, 'Obversaciones')->textarea() ?>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
            <?= Html::submitButton('Guardar', ['class' => 'btn btn-primary',]) ?>  
        </div>
        <?php ActiveForm::end(); ?>
    </div>
</div>