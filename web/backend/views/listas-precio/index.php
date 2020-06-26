<?php

use common\models\ListasPrecio;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Listas de Precios';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline',]); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?= $form->field($busqueda, 'Check')->checkbox(array('class' => 'check--buscar-form', 'label' => 'Incluir dados de baja', 'value' => 'S', 'uncheck' => 'N')); ?>

            <?php ActiveForm::end(); ?>
        </div>

 
        <?php if (PermisosHelper::tienePermiso('AltaListaPrecio')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/listas-precio/alta']) ?>" 
                        data-hint="Nueva Lista de Precios">
                    Nueva Lista de Precios
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
                                <th>Lista</th>
                                <th>Porcentaje</th>
                                <th>Estado</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Lista']) ?></td>
                                    <td>% <?= Html::encode($model['Porcentaje']) ?></td>
                                    <td><?= Html::encode(ListasPrecio::ESTADOS[$model['Estado']]) ?></td>
                                    <td><?= Html::encode($model['Observaciones']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                                            <?php if ($model['Lista']!='Por Defecto'): ?>
                                            <?php if (PermisosHelper::tienePermiso('ModificarListaPrecio')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['/listas-precio/editar', 'id' => $model['IdListaPrecio']]) ?>" 
                                                        data-hint="Editar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if ($model['Estado'] == 'B') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarListaPrecio')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['/listas-precio/activar', 'id' => $model['IdListaPrecio']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('ListarHistorialPorcentajesListaPrecio')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['listas-precio/historial', 'id' => $model['IdListaPrecio']]) ?>"
                                                        data-hint="Historial de Porcentajes">
                                                    <i class="fas fa-history" style="color: tomato"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarListaPrecio')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['/listas-precio/borrar', 'id' => $model['IdListaPrecio']]) ?>"
                                                        data-hint="Borrar">
                                                    <i class="fa fa-trash"></i>
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
            <p><strong>No hay listas de precios que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>