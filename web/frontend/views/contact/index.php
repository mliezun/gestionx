<?php

use frontend\models\froms\ContactForm;
use common\assets\CommonAsset;
use yii\web\View;
use yii\bootstrap\ActiveForm;
use yii\helpers\Html;
use yii\helpers\Url;

/* @var $this View */
/* @var $form ActiveForm */
/* @var $model ContactForm */


CommonAsset::register($this);
Yii::$app->language = 'en';
$this->title = 'Contact Form | Numio';
?>

<header class="container">
    <div class="responsive intro-container">
		<div class="app-icon">
			<img alt="Logo" src="img/app-icon.png">
			<p>Numio</p>
		</div>
	</div>
</header>
<section class="container">
    <h1>Contact</h1>
    <?php
        foreach (Yii::$app->session->getAllFlashes() as $key => $message) {
            echo '<div class="alert alert-' . $key . ' alert-dismissable">'
            . '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
            . $message . '</div>';
        }
    ?>
    <div>
        <?php $form = ActiveForm::begin(); ?>

            <?= $form->field($model, 'Email')->input('email', ['placeholder' => 'Email']) ?>

            <?= $form->field($model, 'Subject')->input('text', ['placeholder' => 'Subject']) ?>

            <?= $form->field($model, 'Message')->textarea() ?>

            <?= Html::submitButton('Send', ['class' => 'btn btn-primary', 'name' => 'send-button']) ?> 

        <?php ActiveForm::end(); ?>
    </div>
</section>
