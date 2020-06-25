<?php
use dosamigos\datepicker\DatePicker;

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */
?>

<?=

$form->field($model, $parametro['Parametro'])->widget(
        DatePicker::className(),
    [
    'language' => Yii::$app->language,
    'clientOptions' => [
        'autoclose' => true,
        'format' => Yii::$app->formatter->datepickerFormat,
        'zIndexOffset' => 1050
    ]
]
)->hint(Yii::t("backend", $parametro['ToolTipText']))->label(Yii::t("backend", $parametro['Etiqueta']));
