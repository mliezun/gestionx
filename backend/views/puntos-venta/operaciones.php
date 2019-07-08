<?php

use common\models\PuntosVenta;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Punto de Venta: ' . $model->PuntoVenta;
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="row">
    <div class="col-sm-12">
        <div class="tab-regular">
            <ul class="nav nav-tabs " id="tabs" role="tablist">
                <?= $tabs->Lista() ?>
            </ul>
            <div class="tab-content" id="tabContent">
                <?= $tabs->Contenido() ?>
            </div>
        </div>
    </div>
</div>