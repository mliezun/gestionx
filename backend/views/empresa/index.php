<?php

use yii\bootstrap\ActiveForm;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\web\View;
use common\components\PermisosHelper;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model \common\models\Empresa */
$this->title = 'Parámetros';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Parámetro</th>
                                <th>Descripción</th>
                                <th>Rango</th>
                                <th>Valor</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Parametro']) ?></td>
                                    <td><?= Html::encode($model['Descripcion']) ?></td>
                                    <td><?= Html::encode($model['Rango']) ?></td>
                                    <td><?= Html::encode($model['Valor']) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                                            
                                            <?php if (PermisosHelper::tienePermiso('ModificarParametro')) : ?>
                                                <button type="button" class="btn btn-default"
                                                        data-modal="<?= Url::to(['/empresa/editar', 'id' => $model['Parametro']]) ?>" 
                                                        style="color: dodgerblue"
                                                        data-hint="Editar">
                                                    <i class="fa fa-edit"></i>
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
    </div>
</div>