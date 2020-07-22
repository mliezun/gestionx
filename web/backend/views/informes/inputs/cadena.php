<?php

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */
?>

<?=

$form->field($model, $parametro['Parametro'])->hint($parametro['ToolTipText'])->label($parametro['Etiqueta']);
?>