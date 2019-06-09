<?php

use common\models\Roles;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Roles';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline',]); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(Roles::ESTADOS, ['prompt' => 'Estado']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

 
        <?php if (PermisosHelper::tienePermiso('AltaRol')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/roles/alta']) ?>" 
                        data-hint="Nuevo Rol">
                    Nuevo Rol
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
                                <th>Rol</th>
                                <th>Estado</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Rol']) ?></td>
                                    <td><?= Html::encode(Roles::ESTADOS[$model['Estado']]) ?></td>
                                    <td><?= Html::encode($model['Observaciones']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                                            
                                            <?php if (PermisosHelper::tienePermiso('ModificarRol')) : ?>
                                                <button type="button" class="btn btn-outline-light"
                                                        data-modal="<?= Url::to(['/roles/editar', 'id' => $model['IdRol']]) ?>" 
                                                        data-hint="Editar">
                                                    <i class="fa fa-pencil-alt"></i>
                                                </button>
                                            <?php endif; ?>  
                                            <?php if ($model['Estado'] == 'B' || $model['Estado'] == 'S') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarRol')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['roles/activar', 'id' => $model['IdRol']]) ?>"
                                                            title="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaRol')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['roles/dar-baja', 'id' => $model['IdRol']]) ?>"
                                                            title="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarRol')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['roles/borrar', 'id' => $model['IdRol']]) ?>"
                                                        title="Borrar">
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
            <p><strong>No hay roles que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>