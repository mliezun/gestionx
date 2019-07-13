<?php

use common\models\Bancos;
use common\models\GestorBancos;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Bancos';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline', 'method' => 'GET']); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(Bancos::ESTADOS, ['prompt' => 'Proveedor']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

        <?php if (PermisosHelper::tienePermiso('AltaBanco')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/bancos/alta']) ?>"
                        data-hint="Nuevo Banco">
                    Nuevo Banco
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
                                <th>Banco</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $k=>$model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Banco']) ?></td>
                                    <td><?= Html::encode(Bancos::ESTADOS[$model['Estado']]) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                            
                                            <?php if (PermisosHelper::tienePermiso('ModificarBanco')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['bancos/editar', 'id' => $model['IdBanco']]) ?>"
                                                        data-hint="Modificar">
                                                    <i class="fa fa-edit" style="color: dodgerblue"></i>
                                                </button>
                                            <?php endif; ?>
                                            <?php if ($model['Estado'] == 'B') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarBanco')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['bancos/activar', 'id' => $model['IdBanco']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaBanco')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['bancos/dar-baja', 'id' => $model['IdBanco']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                            <?php if (PermisosHelper::tienePermiso('BorrarBanco')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-ajax="<?= Url::to(['bancos/borrar', 'id' => $model['IdBanco']]) ?>"
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
            <p><strong>No hay bancos que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>