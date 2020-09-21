<?php

use common\models\ListasPrecio;
use common\models\HistorialPorcentajes;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use common\helpers\FechaHelper;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model ListasPrecio */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= ('Historial de porcentajes de la lista de precio: ' . $lista['Lista']) ?></h5>
            <button type="button" class="close" onclick="Main.modalClose()">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <div class="modal-body">
            <?php if (count($models) > 0): ?>
            <div class="card">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table">
                            <thead class="bg-light">
                                <tr class="border-0">
                                    <th>Porcentajes</th>
                                    <th>Fecha de alta</th>
                                    <th>Fecha de baja</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($models as $k=>$model): ?>
                                    <tr>
                                        <td><?= Html::encode($model['Porcentaje']) ?></td>
                                        <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAlta'])) ?></td>
                                        <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaFin'])) ?></td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <?php else: ?>
                <p><strong>No hay historial de porcentajes para esta lista de precios.</strong></p>
            <?php endif; ?>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
        </div>

    </div>
</div>