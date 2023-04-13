<?php
use Yii;
use kartik\datetime\DateTimePicker;

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */
?>

<?=


$form->field($model, $parametro['Parametro'])->widget(
        DateTimePicker::className(),
    [
    'language' => Yii::$app->language,
    'removeButton' => false,
    'pluginOptions' => [
        'autoclose' => true,
        'format' => Yii::$app->formatter->datetimepickerFormat,
        'todayBtn' => true,
        'todayHighlight' => true,
    ],
]
);


?>