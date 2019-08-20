<?php

use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Artículos';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div id="errores"> </div>
        
        <?php if (count($models) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Articulo</th>
                                <th>Proveedor</th>
                                <th>Codigo</th>
                                <th>Descripcion</th>
                                <th>Precio de compra</th>
                                <th>Cantidad</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $k=>$model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Articulo']) ?></td>
                                    <td><?= Html::encode($model['Proveedor']) ?></td>
                                    <td><?= Html::encode($model['Codigo']) ?></td>
                                    <td><?= Html::encode($model['Descripcion']) ?></td>
                                    <td><?= Html::encode($model['PrecioCosto']) ?></td>
                                    <td><?= Html::encode($model['Cantidad']) ?></td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <?php else: ?>
            <p><strong>No hay articulos que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>