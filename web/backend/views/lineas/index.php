<?php

use common\models\Articulos;
use common\helpers\PermisosHelper;
use common\helpers\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\web\JsExpression;
use backend\assets\IngresosAsset;

IngresosAsset::register($this);

/* @var $this View */
/* @var $form ActiveForm */

$this->title = $titulo;
$this->params['breadcrumbs'][] = $anterior;
$this->params['breadcrumbs'][] = $this->title;

$modelJson = json_encode($model);
$lineasJson = json_encode($lineas);
$configMoney = json_encode(Yii::$app->params['maskMoneyOptions']);

$this->registerJs("AltaLineas.init('$urlBase', '$tipoPrecio', $modelJson, $lineasJson, $configMoney);");
?>

<div class="row">
    <div class="col-sm-12">

        <div id="errores"> </div>
        
        <div class="card" v-cloak id="lineas">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table">
                        <thead class="bg-light">
                            <tr class="border-0">
                                <th style="min-width: 200px;">Articulo</th>
                                <th>Cantidad</th>
                                <th>Precio</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="(l, i) in lineas">
                                <td>{{ l.Articulo }}</td>
                                <td>{{ l.Cantidad }}</td>
                                <?php if ($model['Estado'] == 'I'): ?>
                                    <td>
                                        <input ref="precio" class="form-control">
                                    </td>
                                <?php else: ?>
                                    <td>$ {{ l.Precio }}</td>
                                <?php endif; ?>
                                <td>
                                    <?php if ($model['Estado'] == 'E'): ?>
                                    <button type="button" class="btn btn-default"
                                            @click="borrarLinea(i)"
                                            data-hint="Borrar">
                                        <i class="fa fa-times"></i>
                                    </button>
                                    <?php endif; ?>
                                    <?php if ($model['Estado'] == 'I'): ?>
                                    <button type="button" class="btn btn-default"
                                            @click="editarLinea(i)"
                                            data-hint="Editar Precio">
                                        <i class="fa fa-edit"></i>
                                    </button>
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <?php if ($model['Estado'] == 'E'): ?>
                            <tr>
                                <td>
                                    <select ref="articulo" class="form-control"></select>
                                </td>
                                <td>
                                    <input v-model="cantidad" min="0" ref="cantidad" type="number" class="form-control">
                                </td>
                                <td>
                                    <input ref="precio" class="form-control">
                                </td>
                                <td>
                                    <button type="button" class="btn btn-default"
                                            @click="agregar"
                                            data-hint="Agregar">
                                        <i class="fa fa-check"></i>
                                    </button>
                                    <button type="button" class="btn btn-default"
                                            @click="limpiar"
                                            data-hint="Limpiar">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="lineas--bottom">
                <?php if ($model['Estado'] == 'E' or $model['Estado'] == 'I'): ?>
                    <?php if ($tipoPrecio == 'PrecioVenta'): ?>
                    <button  type="button" class="btn btn-secondary"
                        @click="completar"
                        data-hint="Agregar pagos"
                    >
                        Agregar pagos
                    </button>
                    <?php else: ?>
                    <div>
                        <button  type="button" class="btn btn-secondary"
                            @click="completar"
                            data-hint="Completar"
                        >
                            Completar
                        </button>
                        <?php if ($model['Estado'] == 'E'): ?>
                        <button  type="button" class="btn btn-primary"
                            @click="ingresar"
                            data-hint="Solo Ingresar Stock"
                        >
                            Solo Ingresar Stock
                        </button>
                        <?php endif; ?>
                    </div>
                    <?php endif; ?>
                <?php endif; ?>
                <div class="lineas--total">
                    Total: ${{ total }}
                </div>
            </div>
        </div>
    </div>
</div>
<style>
.vs__dropdown-menu {
    z-index: 9999 !important;
    position: relative;
}
</style>