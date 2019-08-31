<?php

use common\models\Articulos;
use common\models\GestorArticulos;
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
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline', 'method' => 'GET']); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(ArrayHelper::map($proveedores, 'IdProveedor', 'Proveedor'), ['prompt' => 'Proveedor']) ?>

            <?= $form->field($busqueda, 'Combo2')->dropDownList(ArrayHelper::map($listas, 'IdListaPrecio', 'Lista'), ['prompt' => 'Lista de Precios']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?= $form->field($busqueda, 'Check')->checkbox(array('class' => 'check--buscar-form', 'label' => 'Incluir dados de baja', 'value' => 'S', 'uncheck' => 'N')); ?>

            <?php ActiveForm::end(); ?>
        </div>

        <?php if (PermisosHelper::tienePermiso('AltaArticulo')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/articulos/alta']) ?>"
                        data-hint="Nuevo Articulo">
                    Nuevo Articulo
                </button>
            </div>
        <?php endif; ?>
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
                                <th>Precios por Defecto</th>
                                <th>Precios por Lista</th>
                                <th>IVA</th>
                                <th>Fecha de alta</th>
                                <th>Estado</th>
                                <th>Acciones</th>
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
                                    <td><?= Html::encode($model['PrecioVenta']) ?></td>
                                    <td>
                                        <ul>
                                        <?php foreach (json_decode($model['PreciosVenta']) as $nombre => $valor): ?>
                                            <li><?= Html::encode($nombre) ?>: <?= Html::encode($valor) ?></li>
                                        <?php endforeach; ?>
                                        </ul>
                                    </td>
                                    <td><?= Html::encode($model['TipoIVA']) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAlta'])) ?></td>
                                    <td><?= Html::encode(Articulos::ESTADOS[$model['Estado']]) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                            
                                            <?php if (PermisosHelper::tienePermiso('ModificarArticulo')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['articulos/editar', 'id' => $model['IdArticulo']]) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('ModificarArticulo')) : ?>
                                                <a class="btn btn-default"
                                                        href="<?= Url::to(['/precios-articulos', 'id' => $model['IdArticulo']]) ?>"
                                                        data-hint="Listas de Precio">
                                                    <i class="fas fa-list-alt" style="color: green"></i>
                                                </a>
                                            <?php endif; ?>
                                            <?php if ($model['Estado'] == 'B') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarArticulo')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['articulos/activar', 'id' => $model['IdArticulo']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaArticulo')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['articulos/dar-baja', 'id' => $model['IdArticulo']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarArticulo')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['articulos/borrar', 'id' => $model['IdArticulo']]) ?>"
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
            <p><strong>No hay articulos que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>