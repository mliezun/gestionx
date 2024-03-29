<?php

use common\models\Clientes;
use common\helpers\PermisosHelper;
use common\helpers\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\LinkPager;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Clientes';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline']); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(Clientes::TIPOS, ['prompt' => 'Tipo']) ?>

            <?= $form->field($busqueda, 'Combo2')->dropDownList(Clientes::ESTADOS, ['prompt' => 'Estado']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        <?php if (PermisosHelper::tieneAlgunPermiso(['AltaCliente', 'BuscarVentasClientes'])) : ?>
            <div class="alta--button">
                <?php if (PermisosHelper::tienePermiso('AltaCliente')) : ?>
                    <button type="button" class="btn btn-primary"
                            data-modal="<?= Url::to(['/clientes/alta?Tipo=F']) ?>"
                            data-hint="Nuevo Cliente (Física)">
                        Nuevo Cliente (Física)
                    </button>
                    <button type="button" class="btn btn-secondary"
                            data-modal="<?= Url::to(['/clientes/alta?Tipo=J']) ?>"
                            data-hint="Nuevo Cliente (Jurídica)">
                        Nuevo Cliente (Jurídica)
                    </button>
                <?php endif; ?>
                <?php if (PermisosHelper::tienePermiso('BuscarVentasClientes')) : ?>
                    <a type="button" class="btn btn-default" style="float: right"
                            href="<?= Url::to(['/clientes/ventas']) ?>"
                            data-hint="Ventas de clientes">
                        Ventas de clientes
                    </a>
                <?php endif; ?>
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
                                <th>Nombre</th>
                                <th>Documento</th>
                                <th>Datos</th>
                                <th>Fecha de Alta</th>
                                <th>Tipo</th>
                                <th>Estado</th>
                                <th>Lista de Precios</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode(Clientes::Nombre($model)) ?></td>
                                    <td><?= Html::encode($model['TipoDocAfip']) ?>: <?= Html::encode($model['Documento']) ?></td>
                                    <td>
                                        <ul>
                                        <?php foreach (json_decode($model['Datos']) as $dato => $valor): ?>
                                            <?php if (isset($valor) && $valor != ''): ?>
                                                <li><?= Html::encode($dato) ?>: <?= Html::encode($valor) ?></li>
                                            <?php endif; ?>
                                        <?php endforeach; ?>
                                        </ul>
                                    </td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAlta'])) ?></td>
                                    <td><?= Html::encode(Clientes::TIPOS[$model['Tipo']]) ?></td>
                                    <td><?= Html::encode(Clientes::ESTADOS[$model['Estado']]) ?></td>
                                    <td><?= Html::encode($model['Lista']) ?></td>
                                    <td><?= Html::encode($model['Observaciones']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if (PermisosHelper::tienePermiso('ModificarCliente')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['clientes/editar', 'id' => $model['IdCliente']]) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['clientes/documentos', 'id' => $model['IdCliente']]) ?>"
                                                        data-hint="Documentos">
                                                    <i class="fas fa-id-card"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BuscarVentasClientes')) : ?>
                                                <a class="btn btn-default"
                                                        href="<?= Url::to(['clientes/ventas', 'id' => $model['IdCliente']]) ?>"
                                                        data-hint="Ventas del cliente">
                                                    <i class="fas fa-money-bill-alt" style="color: green"></i>
                                                </a>
                                            <?php endif; ?>
                                            <a class="btn btn-default"
                                                    href="<?= Url::to(['clientes/cuentas', 'id' => $model['IdCliente']]) ?>"
                                                    data-hint="Historial de Cuenta">
                                                <i class="fas fa-list-alt" style="color: limegreen"></i>
                                            </a>
                                            <?php if ($model['Estado'] == 'B') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarCliente')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-mensaje="¿Desea activar el cliente?"
                                                            data-ajax="<?= Url::to(['clientes/activar', 'id' => $model['IdCliente']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaCliente')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-mensaje="¿Desea dar de baja el cliente?"
                                                            data-ajax="<?= Url::to(['clientes/dar-baja', 'id' => $model['IdCliente']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarCliente')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-mensaje="¿Desea borrar el cliente?"
                                                        data-ajax="<?= Url::to(['clientes/borrar', 'id' => $model['IdCliente']]) ?>"
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
            <p><strong>No hay clientes que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>