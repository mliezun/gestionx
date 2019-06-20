<?php

use common\models\Articulos;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\Html;
use yii\helpers\Url;
use backend\assets\IngresosAsset;

IngresosAsset::register($this);

/* @var $this View */
/* @var $form ActiveForm */
$this->title = 'Ingreso';
$this->params['breadcrumbs'][] = $this->title;

$modelJson = json_encode($model);
$lineasJson = json_encode($lineas);

$this->registerJs("AltaLineas.init($modelJson, $lineasJson);");
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
                            <tr v-for="(l, i) in lineasIngreso">
                                <td>{{ l.Articulo }}</td>
                                <td>{{ l.Cantidad }}</td>
                                <td>$ {{ l.Precio }}</td>
                                <td>
                                    <button type="button" class="btn btn-default"
                                            @click="borrarLinea(i)"
                                            title="Borrar">
                                        <i class="fa fa-times"></i>
                                    </button>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <v-select v-model="articulo" @input="goNext('articulo')" ref="articulo" @search="fetchOptions" :options="options" :reduce="art => art.IdArticulo" label="Articulo"/>
                                </td>
                                <td>
                                    <input v-model="cantidad" @keypress.enter="goNext('cantidad')" ref="cantidad" type="number" class="form-control" placeholer="Cantidad">
                                </td>
                                <td>
                                    <input v-model="precio" @keypress.enter="goNext('precio')" ref="precio" type="number" class="form-control" placeholder="Precio">
                                </td>
                                <td>
                                    <button type="button" class="btn btn-default"
                                            @click="agregar"
                                            title="Agregar">
                                        <i class="fa fa-check"></i>
                                    </button>
                                    <button type="button" class="btn btn-default"
                                            @click="limpiar"
                                            title="Limpiar">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="lineas--total">
                Total: ${{ total }}
            </div>
        </div>
    </div>
</div>