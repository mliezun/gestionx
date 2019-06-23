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
                <?php if (PermisosHelper::tienePermiso('AltaVenta')): ?>
                    <li class="nav-item">
                        <a  id="ventas-tab"
                            href="#ventas"
                            class="nav-link active show"
                            data-toggle="tab"
                            role="tab"
                            aria-controls="ventas"
                            aria-selected="false"
                        >
                            Ventas
                        </a>
                    </li>
                <?php endif; ?>
            </ul>
            <div class="tab-content" id="tabContent">
                <?php if (PermisosHelper::tienePermiso('AltaVenta')): ?>
                    <div    id="ventas"
                            class="tab-pane fade active show"
                            role="tabpanel"
                            aria-labelledby="ventas-tab"
                    >
                        <?= $this->render('tabs/ventas.php') ?>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>