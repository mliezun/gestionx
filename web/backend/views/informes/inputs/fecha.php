<?php
use kartik\date\DatePicker;

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */
?>

<?= $form->field($model, $parametro['Parametro'])->widget(DatePicker::classname(), [
    'options' => [],
    'type' => DatePicker::TYPE_INPUT,
    'pluginOptions' => [
        'autoclose'=> true,
        'format' => 'dd/mm/yyyy'
    ]
])->hint($parametro['ToolTipText'])->label($parametro['Etiqueta']) ?>
