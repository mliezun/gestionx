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
    $opciones = ArrayHelper::merge($opciones, ['T' => Yii::t("backend", "Todos", [])]);
}
?>

<?= $form->field($model, $parametro['Parametro'])->dropDownList($opciones)->hint(Yii::t("backend", $parametro['ToolTipText']))->label(Yii::t("backend", $parametro['Etiqueta']));
