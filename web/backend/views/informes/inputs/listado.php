<?php

use yii\helpers\ArrayHelper;

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */

$gestor = new \common\models\GestorReportes();
$opciones = $gestor->LlenarListadoParametro($parametro['IdModeloReporte'], $parametro['NroParametro']);
foreach ($opciones as &$opcion) {
    $opcion['Nombre'] = Yii::$app->traductor->traducir($opcion['Nombre'], "backend", [$parametro['IdModeloReporte'] . '.' . $parametro['NroParametro']]);
}
$opciones = ArrayHelper::map($opciones, 'Id', 'Nombre');

if ($parametro['ListaTieneTodos'] == 'S') {
    $opciones = ArrayHelper::merge($opciones, ['T' => "Todos"]);
}
?>

<?= $form->field($model, $parametro['Parametro'])->dropDownList($opciones)->hint($parametro['ToolTipText'])->label($parametro['Etiqueta']);
