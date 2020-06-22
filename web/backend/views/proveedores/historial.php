<?php

use common\models\Proveedores;
use common\models\HistorialDescuentos;
use yii\bootstrap4\ActiveForm;
use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use common\components\FechaHelper;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model Articulos */
?>
<div class="modal-dialog">
    <div class="modal-content">

        <div class="modal-header">
            <h5 class="modal-title"><?= ('Historial de descuentos del proveedor: ' . $proveedor['Proveedor']) ?></h5>
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
                                    <th>Descuento</th>
                                    <th>Fecha de alta</th>
                                    <th>Fecha de baja</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($models as $k=>$model): ?>
                                    <tr>
                                        <td><?= Html::encode($model['Descuento']) ?></td>
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
                <p><strong>No hay historial de descuentos para este proveedor.</strong></p>
            <?php endif; ?>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-default" onclick="Main.modalClose()">Cerrar</button>
        </div>

    </div>
</div>