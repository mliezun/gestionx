<?php

/* @var $this \yii\web\View */
/* @var $content string */

use yii\bootstrap\ActiveForm;
use yii\helpers\Html;

$empresa = Yii::$app->session->get('Parametros')['EMPRESA'];
$logo = Yii::$app->session->get('Parametros')['LOGO'];

$this->title = 'Iniciar sesión - ' . $empresa;
?>
<?php $form = ActiveForm::begin([
    'id' => 'login-form',
    'options' => ['class' => 'form-signin'],
]); ?>

    <img class="mb-4" src="<?= $logo ?>" alt="" width="72" height="72">

    <h1 class="h3 mb-3 font-weight-normal">Iniciar sesión</h1>

    <?php
    foreach (Yii::$app->session->getAllFlashes() as $key => $message) {
        echo '<div class="alert alert-' . $key . ' alert-dismissable">'
        . '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
        . $message . '</div>';
    }

    ?>
    

    <?= $form->field($model, 'Usuario', [
        'inputOptions' => ['placeholder' => 'Usuario'],
    ])->textInput(['autofocus' => true])->label(false) ?>

    <?= $form->field($model, 'Password', [
        'inputOptions' => ['placeholder' => 'Contraseña'],
    ])->passwordInput()->label(false) ?>
                                                    
    <?= Html::submitButton('Iniciar', ['class' => 'btn btn-lg btn-primary btn-block', 'name' => 'login-button']) ?>  

    <p class="mt-5 mb-3 text-muted"><?= Html::encode(Yii::$app->name) ?> © <?= date('Y') ?></p>

<?php ActiveForm::end(); ?>