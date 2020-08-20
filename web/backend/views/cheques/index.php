<?php

use common\models\Cheques;
use common\models\GestorCheques;
use common\helpers\PermisosHelper;
use common\helpers\FechaHelper;
use common\helpers\FormatoHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use kartik\date\DatePicker;
use yii\widgets\LinkPager;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Cheques';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline', 'method' => 'GET']); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

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

            <?= $form->field($busqueda, 'Combo')->dropDownList(Cheques::ESTADOS, ['prompt' => 'Estado']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        
        <div class="alta--button">
            <?php if (PermisosHelper::tienePermiso('AltaChequeCliente')) : ?>
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/cheques/alta', 'Tipo' => 'Cliente']) ?>"
                        data-hint="Nuevo Cheque Cliente">
                    Nuevo Cheque (Cliente)
                </button>
            <?php endif; ?>
            <?php if (PermisosHelper::tienePermiso('AltaChequePropio')) : ?>
                <button type="button" class="btn btn-secondary"
                        data-modal="<?= Url::to(['/cheques/alta', 'Tipo' => 'Propio']) ?>"
                        data-hint="Nuevo Cheque Propio">
                    Nuevo Cheque (Propio)
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
                                <th>Descripcion</th>
                                <th>Banco</th>
                                <th>Destino</th>
                                <th>Nro de Cheque</th>
                                <th>Importe</th>
                                <th>Fecha de Alta</th>
                                <th>Fecha de Vencimiento</th>
                                <th>Estado</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $k=>$model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Descripcion']) ?></td>
                                    <td><?= Html::encode($model['Banco']) ?></td>
                                    <td><?= Html::encode($model['Destino']) ?></td>
                                    <td><?= Html::encode($model['NroCheque']) ?></td>
                                    <td><?= Html::encode(FormatoHelper::formatearMonto($model['Importe'])) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAlta'])) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDateLocal($model['FechaVencimiento'])) ?></td>
                                    <td><?= Html::encode(Cheques::ESTADOS[$model['Estado']]) ?></td>
                                    <td><?= Html::encode($model['Obversaciones']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                            
                                            <?php if (PermisosHelper::algunPermisoContiene('ModificarCheque')) : ?>
                                                <?php if ($model['Descripcion'] == 'Cheque propio') : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['cheques/editar', 'id' => $model['IdCheque'], 'Tipo' => 'Propio']) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                                <?php else : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['cheques/editar', 'id' => $model['IdCheque'], 'Tipo' => 'Cliente']) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if ($model['Estado'] == 'B') : ?>
                                                <?php if (PermisosHelper::tienePermiso('TODO:ActivarCheque')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-mensaje="¿Desea activar el cheque?"
                                                            data-ajax="<?= Url::to(['cheques/activar', 'id' => $model['IdCheque']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('TODO:DarBajaCheque')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-mensaje="¿Desea dar de baja el cheque?"
                                                            data-ajax="<?= Url::to(['cheques/dar-baja', 'id' => $model['IdCheque']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::algunPermisoContiene('BorrarCheque')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-mensaje="¿Desea borrar el cheque?"
                                                        data-ajax="<?= Url::to(['cheques/borrar', 'id' => $model['IdCheque']]) ?>"
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
            <p><strong>No hay cheques que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>