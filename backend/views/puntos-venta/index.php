<?php

use common\models\PuntosVenta;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Puntos de Venta';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline',]); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(PuntosVenta::ESTADOS, ['prompt' => 'Estado']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

 
        <?php if (PermisosHelper::tienePermiso('AltaPuntoVenta')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/puntos-venta/alta']) ?>" 
                        data-hint="Nuevo Punto de Venta">
                    Nuevo Punto de Venta
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
                                <th>Punto de Venta</th>
                                <th>Datos</th>
                                <th>Estado</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['PuntoVenta']) ?></td>
                                    <td><?= Html::encode($model['Datos']) ?></td>
                                    <td><?= Html::encode(PuntosVenta::ESTADOS[$model['Estado']]) ?></td>
                                    <td><?= Html::encode($model['Observaciones']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                                            
                                            <?php if (PermisosHelper::tienePermiso('ModificarPuntoVenta')) : ?>
                                                <button type="button" class="btn btn-outline-light"
                                                        data-modal="<?= Url::to(['/puntos-venta/editar', 'id' => $model['IdPuntoVenta']]) ?>" 
                                                        data-hint="Editar">
                                                    <i class="fa fa-pencil-alt"></i>
                                                </button>
                                            <?php endif; ?>  
                                            <?php if ($model['Estado'] == 'B' || $model['Estado'] == 'S') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarPuntoVenta')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['puntos-venta/activar', 'id' => $model['IdPuntoVenta']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaPuntoVenta')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['puntos-venta/dar-baja', 'id' => $model['IdPuntoVenta']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarPuntoVenta')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['puntos-venta/borrar', 'id' => $model['IdPuntoVenta']]) ?>"
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
            <p><strong>No hay puntos de venta que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>