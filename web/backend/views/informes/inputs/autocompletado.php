<?php

use kartik\select2\Select2;
use yii\web\JsExpression;
use yii\helpers\Url;

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */

$url = Url::to(['/informes/autocompletar', 'idModeloReporte' => $parametro['IdModeloReporte'], 'nroParametro' => $parametro['NroParametro']]);

$initScript = <<<SCRIPT
    function (element, callback) {
        var id=\$(element).val();
        if (id !== "") {
            \$.ajax("{$url}&id=" + id , {
                dataType: "json"
            }).done(function(data) { callback(data);});
        } else callback([]);
    }
SCRIPT;
?>

<?=

$form->field($model, $parametro['Parametro'])->widget(Select2::classname(), [
                            'theme' => Select2::THEME_DEFAULT,
    'options' => ['placeholder' => 'Ingresar más de 4 caracteres.'],
    'pluginOptions' => [
        'minimumInputLength' => 4,
        'allowClear' => true,
        'ajax' => [
            'delay' => 1000 , //delay en milisegundos antes de ir a buscar en la bd
            'url' => $url,
            'dataType' => 'json',
            'data' => new JsExpression('function(param) { return {cadena:param.term}; }'),
            'processResults' => new JsExpression('function(data,page) { return {results:data}; }'),
        ],
        'initSelection' => new JsExpression($initScript)
    ],
])->hint($parametro['ToolTipText'])->label($parametro['Etiqueta']);
?>