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
use kartik\select2\Select2;
use yii\widgets\LinkPager;

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

            <?= $form->field($busqueda, 'Combo')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($proveedores, 'IdProveedor', 'Proveedor'),
                'language' => 'es',
                'options' => ['placeholder' => 'Proveedor'],
                'pluginOptions' => [
                    'allowClear' => true,
                    'width' => '243px'
                ],
            ]) ?>

            <?= $form->field($busqueda, 'Combo2')->widget(Select2::classname(), [
                'data' => ArrayHelper::map($listas, 'IdListaPrecio', 'Lista'),
                'language' => 'es',
                'options' => ['placeholder' => 'Lista de Precios'],
                'pluginOptions' => [
                    'allowClear' => true,
                    'width' => '243px'
                ]
            ]) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button', 'style' => 'margin-left: 10px']) ?> 

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
                                <?php if (PermisosHelper::tienePermiso('VerPrecioArticulo')) : ?>
                                    <th>Precio de compra</th>
                                <?php endif; ?>
                                <?php foreach (json_decode($models[0]['PreciosVenta']) as $nombre => $valor): ?>
                                    <th><?= Html::encode('Precio ' . $nombre) ?></th>
                                <?php endforeach; ?>
                                <th>Existencias</th>
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
                                    <?php if (PermisosHelper::tienePermiso('VerPrecioArticulo')) : ?>
                                        <td><?= Html::encode($model['PrecioCosto']) ?></td>
                                    <?php endif; ?>
                                    <?php foreach (json_decode($model['PreciosVenta']) as $nombre => $valor): ?>
                                        <td><?= Html::encode($valor) ?></td>
                                    <?php endforeach; ?>
                                    <td>
                                    <?php foreach (json_decode($model['Existencias'], true) as $existencias): ?>
                                    <div>
                                        <strong><?= Html::encode("{$existencias['PuntoVenta']}") ?>:</strong>
                                            <?= Html::encode("{$existencias['Cantidad']}") ?>
                                            </div>
                                    <?php endforeach; ?>
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
                                            <?php if (PermisosHelper::tienePermiso('ListarHistorialPreciosArticulo')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['articulos/historial', 'id' => $model['IdArticulo']]) ?>"
                                                        data-hint="Historial de Precios">
                                                    <i class="fas fa-history" style="color: tomato"></i>
                                                </button>
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
                                            <?php if (PermisosHelper::tienePermiso('TODO:BorrarArticulo')) : ?>
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
        <div class="pull-right">
            <?=
            LinkPager::widget([
                'pagination' => $paginado,
                'firstPageLabel' => '<<',
                'lastPageLabel' => '>> ',
                'nextPageLabel' => '>',
                'prevPageLabel' => '<',
                'pageCssClass' => 'page-link',
                'activePageCssClass' => 'page-item-active',
                'firstPageCssClass' => 'page-link',
                'lastPageCssClass' => 'page-link',
                'nextPageCssClass' => 'page-link',
                'prevPageCssClass' => 'page-link',
            ]);
            ?>
        </div>
        <div class="clearfix"></div>
        <?php else: ?>
            <p><strong>No hay articulos que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>