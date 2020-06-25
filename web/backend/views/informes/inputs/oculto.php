<?php

/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $parametro [] */

$model->{$parametro['Parametro']} = $parametro['ValorNoEsUsaComun'];

?>

<?=
$form->field($model, $parametro['Parametro'])->hiddenInput()->label('');
