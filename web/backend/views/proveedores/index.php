<?php

use common\models\Proveedores;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\LinkPager;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Proveedores';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline', 'method' => 'GET']); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?= $form->field($busqueda, 'Check')->checkbox(array('class' => 'check--buscar-form', 'label' => 'Incluir dados de baja', 'value' => 'S', 'uncheck' => 'N')); ?>

            <?php ActiveForm::end(); ?>
        </div>

        <div class="alta--button">
            <?php if (PermisosHelper::tienePermiso('AltaProveedor')) : ?>
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/proveedores/alta']) ?>"
                        data-hint="Nuevo Proveedor">
                    Nuevo Proveedor
                </button>
            <?php endif; ?>
        </div>

        <div id="errores"> </div>
        
        <?php if (count($models) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Proveedor</th>
                                <th>Descuento</th>
                                <th>Estado</th>
                                <?php if (Yii::$app->user->identity->IdEmpresa == 1) : ?>
                                    <th>Deuda</th>
                                <?php endif; ?>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Proveedor']) ?></td>
                                    <td>% <?= Html::encode($model['Descuento']) ?></td>
                                    <td><?= Html::encode(Proveedores::ESTADOS[$model['Estado']]) ?></td>
                                    <?php if (Yii::$app->user->identity->IdEmpresa == 1) : ?>
                                        <?php
                                        $deuda = $model['Deuda'];
                                        $estilo = '';
                                        if ($deuda > 0) {
                                            $estilo = ' style="color: red; font-weight: bold; font-size: 20px" ';
                                        } elseif($deuda < 0) {
                                            $deuda = - $deuda . " a favor";
                                            $estilo = ' style="color: green; font-weight: bold; font-size: 20px" ';
                                        } else {
                                            $estilo = ' style="font-weight: bold" ';
                                        }
                                        echo "<td $estilo>";
                                        echo Html::encode($deuda);
                                        echo '</td>';
                                        ?>
                                    <?php endif; ?>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">

                                            <?php if (Yii::$app->user->identity->IdEmpresa == 1) : ?>
                                                <a class="btn btn-default"
                                                        href="<?= Url::to(['proveedores/cuentas', 'id' => $model['IdProveedor']]) ?>"
                                                        data-hint="Historial de Cuenta">
                                                    <i class="fas fa-list-alt" style="color: green"></i>
                                                </a>
                                            <?php endif; ?>

                                            <?php if (PermisosHelper::tienePermiso('ModificarProveedor')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['proveedores/editar', 'id' => $model['IdProveedor']]) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['proveedores/aumento', 'id' => $model['IdProveedor']]) ?>"
                                                        data-hint="Aumentar precios">
                                                    <i class="fa fa-arrow-up" style="color: gray"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('AltaArticulo')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['proveedores/cargar', 'id' => $model['IdProveedor']]) ?>"
                                                        data-hint="Cargar artículos">
                                                    <i class="fa fa-list" style="color: orange"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if ($model['Estado'] == 'B') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarProveedor')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['proveedores/activar', 'id' => $model['IdProveedor']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaProveedor')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['proveedores/dar-baja', 'id' => $model['IdProveedor']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('ListarHistorialDescuentosProveedor')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['proveedores/historial', 'id' => $model['IdProveedor']]) ?>"
                                                        data-hint="Historial de Descuentos">
                                                    <i class="fas fa-history" style="color: tomato"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarProveedor')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['proveedores/borrar', 'id' => $model['IdProveedor']]) ?>"
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
            <p><strong>No hay proveedores que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>