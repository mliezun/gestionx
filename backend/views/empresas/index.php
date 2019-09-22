<?php

use yii\bootstrap\ActiveForm;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\web\View;
use common\components\PermisosHelper;
use common\models\EmpresasModel;
use yii\widgets\LinkPager;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model \common\models\Empresa */
$this->title = 'Empresas';
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">

        <div class="buscar--form">
            <?php $form = ActiveForm::begin(['layout' => 'inline', 'method' => 'GET']); ?>

            <?= $form->field($busqueda, 'Cadena')->input('text', ['placeholder' => 'Búsqueda']) ?>

            <?= Html::submitButton('Buscar', ['class' => 'btn btn-primary', 'name' => 'pregunta-button']) ?> 

            <?= $form->field($busqueda, 'Check')->checkbox(array('class' => 'check--buscar-form', 'label' => 'Incluir dados de baja', 'value' => 'S', 'uncheck' => 'N')); ?>

            <?php ActiveForm::end(); ?>
        </div>

        <?php if (PermisosHelper::tienePermiso('AltaEmpresa')) : ?>
            <div class="alta--button">
                <button type="button" class="btn btn-primary"
                        data-modal="<?= Url::to(['/empresas/alta']) ?>"
                        data-hint="Nuevo Proveedor">
                    Nueva Empresa
                </button>
            </div>
        <?php endif; ?>

        <div id="errores"> </div>

        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Empresa</th>
                                <th>URL</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode($model['Empresa']) ?></td>
                                    <td><?= Html::encode($model['URL']) ?></td>
                                    <td><?= Html::encode(EmpresasModel::ESTADOS[$model['Estado']]) ?></td>
                                    <td>

                                        <div class="btn-group" role="group" aria-label="...">
                                            
                                            <?php if ($model['Estado'] == 'B') : ?>
                                                <?php if (PermisosHelper::tienePermiso('ActivarEmpresa')): ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['empresas/activar', 'id' => $model['IdEmpresa']]) ?>"
                                                            data-hint="Activar">
                                                        <i class="fa fa-check-circle" style="color: green"></i>
                                                    </button>
                                                <?php endif; ?>
                                            <?php else : ?>
                                                <?php if (PermisosHelper::tienePermiso('DarBajaEmpresa')) : ?>
                                                    <button type="button" class="btn btn-default"
                                                            data-ajax="<?= Url::to(['empresas/dar-baja', 'id' => $model['IdEmpresa']]) ?>"
                                                            data-hint="Dar baja">
                                                        <i class="fa fa-minus-circle" style="color: red"></i>
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
    </div>
</div>