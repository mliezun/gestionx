<?php


/* @var $this yii\web\View */
/* @var $form yii\bootstrap\ActiveForm */
/* @var $model \common\models\forms\AuditoriaForm */
?>

<?= $form->field($model, 'Motivo')->textInput(['v-model' => 'AuditoriaForm.Motivo', 'autocomplete' => 'off']) ?>
<?= $form->field($model, 'Autoriza')->dropDownList($autorizadores, ['prompt' => 'Usuario que autoriza la operación', 'v-model' => 'AuditoriaForm.Autoriza']) ?>