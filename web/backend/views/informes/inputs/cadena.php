<?php

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */
?>

<?=

$form->field($model, $parametro['Parametro'])->hint(Yii::t("backend", $parametro['ToolTipText']))->label(Yii::t("backend", $parametro['Etiqueta']));
?>