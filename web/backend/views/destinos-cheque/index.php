<?php

use common\models\DestinosCheque;
use common\helpers\PermisosHelper;
use common\helpers\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Destinos de cheques';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline',]); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= $form->field($busqueda, 'Combo')->dropDownList(DestinosCheque::ESTADOS, ['prompt' => 'Estado']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?php ActiveForm::end(); ?>
        </div>

 
        <?php if (PermisosHelper::tienePermiso('AltaListaPrecio')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/destinos-cheque/alta']) ?>" 
                        data-hint="Nuevo Destino de Cheques">
                    Nuevo Destino de Cheques
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
                                <th>Destino</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Destino']) ?></td>
                                    <td><?= Html::encode(DestinosCheque::ESTADOS[$model['Estado']]) ?></td>
                                    <td>

                                    <div class="btn-group" role="group" aria-label="...">
                            
                                        <?php if (PermisosHelper::tienePermiso('ModificarDestinoCheque')) : ?>
                                            <button type="button" class="btn btn-default"
                                                    data-modal="<?= Url::to(['destinos-cheque/editar', 'id' => $model['IdDestinoCheque']]) ?>"
                                                    data-hint="Modificar">
                                                <i class="fa fa-edit" style="color: dodgerblue"></i>
                                            </button>
                                        <?php endif; ?>
                                        <?php if ($model['Estado'] == 'B') : ?>
                                            <?php if (PermisosHelper::tienePermiso('ActivarDestinoCheque')): ?>
                                                <button type="button" class="btn btn-default"
                                                        data-mensaje="¿Desea activar el destino de cheque?"
                                                        data-ajax="<?= Url::to(['destinos-cheque/activar', 'id' => $model['IdDestinoCheque']]) ?>"
                                                        data-hint="Activar">
                                                    <i class="fa fa-check-circle" style="color: green"></i>
                                                </button>
                                            <?php endif; ?>
                                        <?php else : ?>
                                            <?php if (PermisosHelper::tienePermiso('DarBajaDestinoCheque')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-mensaje="¿Desea dar de baja el destino de cheque?"
                                                        data-ajax="<?= Url::to(['destinos-cheque/dar-baja', 'id' => $model['IdDestinoCheque']]) ?>"
                                                        data-hint="Dar baja">
                                                    <i class="fa fa-minus-circle" style="color: red"></i>
                                                </button>
                                            <?php endif; ?>
                                        <?php endif; ?>
                                        <?php if (PermisosHelper::tienePermiso('BorrarDestinoCheque')) : ?>
                                            <button type="button" class="btn btn-default"
                                                    data-mensaje="¿Desea borrar el destino de cheque?"
                                                    data-ajax="<?= Url::to(['destinos-cheque/borrar', 'id' => $model['IdDestinoCheque']]) ?>"
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
            <p><strong>No hay destinos de cheques que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>