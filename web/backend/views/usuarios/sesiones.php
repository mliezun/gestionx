<?php

use common\models\Usuarios;
use common\helpers\PermisosHelper;
use common\helpers\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\LinkPager;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Sesiones - Usuario: ' . $model->Usuario;
$this->params['breadcrumbs'][] = [
    'label' => 'Usuarios',
    'link' => '/usuarios'
];
$this->params['breadcrumbs'][] = $this->title;
?>

<div class="row">
    <div class="col-sm-12">
        <div class="buscar--form">

        </div>


        <div id="errores"> </div>
        
        <?php if (count($models) > 0): ?>
        <div class="card">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th>Fecha de inicio</th>
                                <th>Fecha de fin</th>
                                <th>IP</th>
                                <th>Aplicacion</th>
                                <th>UserAgent</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($models as $model): ?>
                                <tr>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaInicio'])) ?></td>
                                    <td><?= Html::encode(FechaHelper::formatearDatetimeLocal($model['FechaFin'])) ?></td>
                                    <td><?= Html::encode($model['IP']) ?></td>
                                    <td><?= Html::encode(Usuarios::APLICACIONES[$model['Aplicacion']]) ?></td>
                                    <td><?= Html::encode($model['UserAgent']) ?></td>
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
            <p><strong>No hay usuarios que coincidan con el criterio de búsqueda utilizado.</strong></p>
        <?php endif; ?>
    </div>
</div>