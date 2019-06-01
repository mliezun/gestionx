<?php

use common\models\forms\CambiarPasswordForm;
use yii\bootstrap\ActiveForm;
use yii\helpers\Html;
use yii\web\View;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model CambiarPasswordForm */

$this->title = 'Nueva contraseña';
?>
<h3 class="login-box-msg"><?= Html::encode($this->title) ?></h3>
<div class="login-box-body">
    <?php $form = ActiveForm::begin(); ?>
    <div>

        <?php
        foreach (Yii::$app->session->getAllFlashes() as $key => $message) {
            echo '<div class="alert alert-' . $key . ' alert-dismissable">'
            . '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
            . $message . '</div>';
        }

        ?>
        <?= $form->field($model, 'Anterior')->passwordInput() ?>

        <?= $form->field($model, 'Password')->passwordInput() ?>

        <?= $form->field($model, 'Password_repeat')->passwordInput() ?>
    </div>

    <div class="footer">                                                               
        <?= Html::submitButton('Cambiar contraseña', ['class' => 'btn bg-olive btn-block',]) ?>  

    </div>
    <?php ActiveForm::end(); ?>
</div>