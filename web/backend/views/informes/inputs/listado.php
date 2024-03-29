<?php

use yii\helpers\ArrayHelper;

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */

$gestor = new \common\models\GestorReportes();
$opciones = $gestor->LlenarListadoParametro($parametro['IdModeloReporte'], $parametro['NroParametro']);
$opciones = ArrayHelper::map($opciones, 'Id', 'Nombre');
?>

<?= $form->field($model, $parametro['Parametro'])->dropDownList($opciones)->hint($parametro['ToolTipText'])->label($parametro['Etiqueta']);
