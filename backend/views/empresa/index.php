<?php

use yii\bootstrap\ActiveForm;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\web\View;
use common\components\PermisosHelper;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model \common\models\Preguntas */
?>
<!-- ============================================================== -->
<!-- pageheader  -->
<!-- ============================================================== -->
<div class="row">
    <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
        <div class="page-header">
            <h2 class="pageheader-title">Parámetros</h2>
            <div class="page-breadcrumb">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="/" class="breadcrumb-link">Inicio</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Parámetros</li>
                    </ol>
                </nav>
            </div>
        </div>
    </div>
</div>
<!-- ============================================================== -->
<!-- end pageheader  -->
<!-- ============================================================== -->
<div class="ecommerce-widget">

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
                                                
                                                <?php if (PermisosHelper::tienePermiso('ModificaParametro')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-modal="<?= Url::to(['/empresa/editar', 'id' => $model['Parametro']]) ?>" 
                                                            data-hint="Editar">
                                                        <i class="fa fa-pencil-alt"></i>
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
</div>