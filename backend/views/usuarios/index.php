<?php

use common\models\Usuarios;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Usuarios';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline',]); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(Usuarios::ESTADOS, ['prompt' => 'Estado']) ?>

            <?= $form->field($busqueda, 'Combo2')->dropDownList(ArrayHelper::map($roles, 'IdRol', 'Rol'), ['prompt' => 'Rol']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        <?php if (PermisosHelper::tienePermiso('AltaUsuario')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/usuarios/alta']) ?>" 
                        data-hint="Nuevo Usuario">
                    Nuevo Usuario
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
                                <th>Usuario</th>
                                <th>Rol</th>
                                <th>Nombres</th>
                                <th>Apellidos</th>
                                <th>Email</th>
                                <th>Fecha Alta</th>
                                <th>Estado</th>
                                <th>Observaciones</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Usuario']) ?></td>
                                    <td><?= Html::encode($model['Rol']) ?></td>
                                    <td><?= Html::encode($model['Nombres']) ?></td>
                                    <td><?= Html::encode($model['Apellidos']) ?></td>
                                    <td><?= Html::encode($model['Email']) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaAlta'])) ?></td>
                                    <td><?= Html::encode(Usuarios::ESTADOS[$model['Estado']]) ?></td>
                                    <td><?= Html::encode($model['Observaciones']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                            
                                            <?php if (PermisosHelper::tienePermiso('ModificarUsuario')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['usuarios/editar', 'id' => $model['IdUsuario']]) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('RestablecerPassword')): ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['usuarios/restablecer-pass', 'id' => $model['IdUsuario']]) ?>"
                                                        data-hint="Restablecer Password">
                                                    <i class="fas fa-key"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if ($model['Estado'] == 'B' || $model['Estado'] == 'S') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarUsuario')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['usuarios/activar', 'id' => $model['IdUsuario']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaUsuario')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['usuarios/dar-baja', 'id' => $model['IdUsuario']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarUsuario')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['usuarios/borrar', 'id' => $model['IdUsuario']]) ?>"
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
            <p><strong>No hay usuarios que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>