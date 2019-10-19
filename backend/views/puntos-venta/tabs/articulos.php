<?php

use common\components\PermisosHelper;
use common\components\FechaHelper;
use common\models\RectificacionesPV;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\LinkPager;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Artículos';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline',]); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?>

             <?= $form->field($busqueda, 'Check')->checkbox(array('class' => 'check--buscar-form', 'label' => 'Incluir sin stock', 'value' => 'S', 'uncheck' => 'N')); ?> 

             <?= $form->field($busqueda, 'Check2')->checkbox(array('class' => 'check--buscar-form', 'label' => 'Incluir no pendientes', 'value' => 'S', 'uncheck' => 'N')); ?> 

            <?php ActiveForm::end(); ?>
        </div>
        <?php if (PermisosHelper::tienePermiso('AltaRectificacion')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/rectificaciones/alta', 'id' => $puntoventa['IdPuntoVenta']]) ?>"
                        data-hint="Nueva Rectificación">
                    Nueva Rectificación
                </button>
            </div>
        <?php endif; ?>

        <div id="errores"> </div>

        <?php if (count($rectificaciones) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Origen</th>
                                <th>Destino</th>
                                <th>Articulo</th>
                                <th>Cantidad</th>
                                <th>Estado</th>
                                <th>Fecha de Alta</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($rectificaciones as $k=>$recti): ?>
                                <tr>
                                    <td><?= Html::encode($recti['PuntoVentaOrigen']) ?></td>
                                    <td><?= Html::encode($recti['PuntoVentaDestino']) ?></td>
                                    <td><?= Html::encode($recti['Articulo']) ?></td>
                                    <td><?= Html::encode($recti['Cantidad']) ?></td>
                                    <td><?= Html::encode(RectificacionesPV::ESTADOS[$recti['Estado']]) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($recti['FechaAlta'])) ?></td>
                                    <td><?= Html::encode($recti['Observaciones']) ?></td>
                                    <td>
                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if ($puntoventa['IdPuntoVenta'] == $recti['IdPuntoVentaDestino']) : ?>
                                                <?php if ($recti['Estado'] == 'P' && PermisosHelper::tienePermiso('ConfirmarRectificacion')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['rectificaciones/confirmar', 'id' => $recti['IdRectificacionPV']]) ?>"
                                                            data-hint="Confirmar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if ($recti['Estado'] == 'P' && PermisosHelper::tienePermiso('BorrarRectificacion')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['rectificaciones/borrar', 'idPv' => $puntoventa['IdPuntoVenta'], 'idRec' => $recti['IdRectificacionPV']]) ?>"
                                                            data-hint="Borrar">
                                                        <i class="fa fa-trash"></i>
                                                    </button>
                                                <?php endif; ?>
                                                <?php if ($recti['Estado'] == 'P' && PermisosHelper::tienePermiso('DevolucionRectificacion')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['rectificaciones/devolver', 'idPv' => $puntoventa['IdPuntoVenta'], 'idRec' => $recti['IdRectificacionPV']]) ?>"
                                                            data-hint="Devolver">
                                                        <i class="fa fa-undo-alt"></i>
                                                    </button>
                                                <?php endif; ?>
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
            <p><strong>No hay rectificaciones que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
        
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