<?php

/* @var $this yii\web\View */
/* @var $name string */
/* @var $message string */
/* @var $exception Exception */

use yii\helpers\Html;

$this->title = $name;
?>
<div class="site-error">

    <h1><?= Html::encode($this->title) ?></h1>

    <div class="alert alert-danger">
        <?= nl2br(Html::encode($message)) ?>
    </div>

    <p>
        Este error ocurrió mientras el servidor intentaba procesar su pedido.
    </p>
    <p>
        Por favor, contáctese con nosotros si el problema persiste. Muchas gracias.
    </p>

</div>
