<?php

/* @var $this \yii\web\View */
/* @var $content string */

use backend\assets\LoginAsset;
use yii\bootstrap\ActiveForm;
use yii\helpers\Html;

LoginAsset::register($this);
$this->title = 'Iniciar sesión - GestionX';
?>
<?php $this->beginPage() ?>
<!DOCTYPE html>
<html lang="<?= Yii::$app->language ?>">
<head>
    <meta charset="<?= Yii::$app->charset ?>">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php $this->registerCsrfMetaTags() ?>
    <title><?= Html::encode($this->title) ?></title>
    <?php $this->head() ?>
</head>
<body class="text-center">
<?php $this->beginBody() ?>

    <?php $form = ActiveForm::begin([
        'id' => 'login-form',
        'options' => ['class' => 'form-signin'],
    ]); ?>

        <img class="mb-4" src="/img/brand/gestionx-solid.svg" alt="" width="72" height="72">

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
                                                     
        <?= Html::submitButton('Login', ['class' => 'btn btn-lg btn-primary btn-block', 'name' => 'login-button']) ?>  

        <p class="mt-5 mb-3 text-muted"><?= Html::encode(Yii::$app->name) ?> © <?= date('Y') ?></p>

    <?php ActiveForm::end(); ?>

<?php $this->endBody() ?>
</body>
</html>
<?php $this->endPage() ?>
