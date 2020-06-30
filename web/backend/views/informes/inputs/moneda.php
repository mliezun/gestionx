<?php

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */
?>

<?=

$form->field($model, $parametro['Parametro'], [
    'inputTemplate' => '<div class="input-group"><span class="input-group-addon">' . Yii::$app->formatter->numberFormatterSymbols[NumberFormatter::CURRENCY_SYMBOL] . '</span>{input}</div>',
])->hint($parametro['ToolTipText'])->label($parametro['Etiqueta']);
