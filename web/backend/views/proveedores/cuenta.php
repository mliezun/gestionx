<?php

use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use common\components\FechaHelper;
use kartik\date\DatePicker;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Articulos */
?>
<div class="modal-dialog modal-lg">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= ('Historial de Cuenta del proveedor: ' . $proveedor['Proveedor']) ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <div class="modal-body">
            <div class="buscar--form">
                <?php $form = ActiveForm::begin(['layout' => 'inline', 'method' => 'GET']); ?>

                <?= $form->field($busqueda, 'FechaInicio')->widget(DatePicker::classname(), [
                'options' => ['placeholder' => 'Fecha desde'],
                'type' => DatePicker::TYPE_INPUT,
                'pluginOptions' => [
                    'autoclose'=> true,
                    'format' => 'dd/mm/yyyy'
                ]
                ]) ?>

                <?= $form->field($busqueda, 'FechaFin')->widget(DatePicker::classname(), [
                    'options' => ['placeholder' => 'Fecha hasta'],
                    'type' => DatePicker::TYPE_INPUT,
                    'pluginOptions' => [
                        'autoclose'=> true,
                        'format' => 'dd/mm/yyyy'
                    ]
                ]) ?>

                <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

                <?php ActiveForm::end(); ?>
            </div>

            <?php if (count($models) > 0): ?>
            <div class="card">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table">
                            <thead class="bg-light">
                                <tr class="border-0">
                                    <th>Fecha</th>
                                    <th>Motivo</th>
                                    <th>Monto</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($models as $k=>$model): ?>
                                    <tr>
                                        <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['Fecha'])) ?></td>
                                        <td><?= Html::encode($model['Motivo']) ?></td>
                                        <td><?= Html::encode($model['Monto']) ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <?php else: ?>
                <p><strong>No hay historial de descuentos para este proveedor.</strong></p>
            <?php endif; ?>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
        </div>

    </div>
</div>