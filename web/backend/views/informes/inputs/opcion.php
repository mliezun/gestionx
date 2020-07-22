<?php

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */
?>

<?= $form->field($model, $parametro['Parametro'])->checkbox(['value' => 'S', 'uncheck' => 'N'])->hint($parametro['ToolTipText'])->label($parametro['Etiqueta']);
