<?php

use common\models\PreciosArticulos;
use common\models\Articulos;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = $titulo;
$this->params['breadcrumbs'][] = $anterior;
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <?php if (PermisosHelper::tienePermiso('ModificarArticulo')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/precios-articulos/alta', 'id' => $model['IdArticulo']]) ?>"
                        data-hint="Nuevo Precio por Lista">
                    Nuevo Precio por Lista
                </button>
            </div>
        <?php endif; ?>

        <div id="errores"> </div>
        
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
                                <th>Precios por Defecto</th>
                                <th>Precios por Lista</th>
                                <th>Gravamen</th>
                                <th>Fecha de alta</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                                <tr>
                                    <td><?= Html::encode($model['Articulo']) ?></td>
                                    <td><?= Html::encode($model['Proveedor']) ?></td>
                                    <td><?= Html::encode($model['Codigo']) ?></td>
                                    <td><?= Html::encode($model['Descripcion']) ?></td>
                                    <td><?= Html::encode($model['PrecioCosto']) ?></td>
                                    <td><?= Html::encode($model['PrecioVenta']) ?></td>
                                    <td>
                                        <ul>
                                        <?php foreach (json_decode($model['PreciosVenta']) as $nombre => $valor): ?>
                                            <li><?= Html::encode($nombre) ?>: <?= Html::encode($valor) ?></li>
                                        <?php endforeach; ?>
                                        </ul>
                                    </td>
                                    <td><?= Html::encode($model['Gravamen']) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAlta'])) ?></td>
                                    <td><?= Html::encode(Articulos::ESTADOS[$model['Estado']]) ?></td>
                                </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <?php if (count($precios) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Lista</th>
                                <th>Precio Venta</th>
                                <th>Fecha de Alta</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($precios as $precio): ?>
                                <tr>
                                    <td><?= Html::encode($precio['Lista']) ?></td>
                                    <td><?= Html::encode($precio['PrecioVenta']) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($precio['FechaAlta'])) ?></td>
                                    <td>
                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if (PermisosHelper::tienePermiso('ModificarArticulo')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['precios-articulos/editar', 'idArt' => $precio['IdArticulo'], 'idLis' => $precio['IdListaPrecio']]) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('ModificarArticulo') && $precio['Lista']!= 'Por Defecto') : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['precios-articulos/borrar', 'idArt' => $precio['IdArticulo'], 'idLis' => $precio['IdListaPrecio']]) ?>"
                                                        data-hint="Borrar">
                                                    <i class="fa fa-trash"></i>
                                                </button>
                                            <?php endif; ?>
                                        </div>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <?php else: ?>
            <p><strong>No hay precios que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>