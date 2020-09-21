<?php

use backend\assets\RolesAsset;
use common\helpers\PermisosHelper;
use yii\bootstrap\ActiveForm;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\web\View;

/* @var $this View */

RolesAsset::register($this);
$this->registerJs('Roles.Permisos.init()');

$estados = [
    'A' => 'Activo',
    'B' => 'Baja'
];

$this->title = 'Permisos del rol ' . $model->Rol;
$this->params['breadcrumbs'][] = [
    'label' => 'Roles',
    'link' => '/roles'
];
$this->params['breadcrumbs'][] = $this->title;

function arbol($permisos, $padre = null)
{
    $edicion = !in_array('AsignarPermisosRol', Yii::$app->session->get('Permisos'));
    echo '<ul>';
    foreach ($permisos as $permiso) {
        if ($permiso['IdPermisoPadre'] == $padre) {
            echo '<li>';
            if ($permiso['EsHoja'] == 'N') {
                echo '<h4>' . Html::checkbox(
                    '',
                    false,
                    ['class' => 'tree-grupo', 'label' => $permiso['Descripcion'], 'disabled' => $edicion,]
                ) . '</h4>';
                arbol($permisos, $permiso['IdPermiso']);
            } else {
                echo Html::checkbox('Permisos[' . $permiso['IdPermiso'] . ']', $permiso['Estado'] == 'S' ? true : false, ['label' => $permiso['Descripcion'],
                    'class' => 'tree-hoja', 'disabled' => $edicion,]);
            }
            echo '</li>';
        }
    }
    echo '</ul>';
}
?>

<div class="row">

    <div class="col-md-7">

        <div class="box box-primary">
            <div class="box-header">
                <i class="fa fa-key"></i>
                <h3 class="box-title">Permisos</h3>
            </div>
            <?php
            $form = ActiveForm::begin([
                        'id' => $model->IdRol,
                        'layout' => 'horizontal'
                    ])
            ?>
            <div class="box-body">

                <?php
                foreach (Yii::$app->session->getAllFlashes() as $key => $message) {
                    echo '<div class="alert alert-' . $key . ' alert-dismissable">'
                    . '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
                    . $message . '</div>';
                }
                ?>

                <div class='tree-container'>
                    <?php arbol($permisos) ?>
                </div>

            </div><!-- /.box-body -->
            <div class="box-footer">
                <div class="pull-right">

                    <?php
                    if (PermisosHelper::tienePermiso('AsignarPermisosRol')):
                        echo Html::submitButton('Guardar', ['class' => 'btn btn-primary',]);
                    endif;
                    ?> 

                    <?= Html::a('Restablecer', Url::to(['roles/permisos', 'id' => $model->IdRol]), ['class' => 'btn btn-default']) ?>
                </div>
                <div class="clearfix"></div>

            </div>
            <?php ActiveForm::end(); ?>
        </div>
    </div>

    <div class="col-md-5">
        <div class="box">
            <div class="box-header">
                <i class="fa fa-group"></i>
                <h3 class="box-title">Rol <?= Html::encode($model->Rol) ?></h3>
            </div>
            <div class="box-body">
                <p><strong>Estado: </strong> <?= Html::encode($estados[$model->Estado]) ?></p>
                <p><strong>Observaciones: </strong> <?= Html::encode($model->Observaciones) ?></p>
            </div>
        </div>
    </div>
</div>