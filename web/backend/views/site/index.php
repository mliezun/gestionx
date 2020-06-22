<?php

use backend\models\Menu;

/* @var $this yii\web\View */

$this->title = 'Módulos del sistema ' . Yii::$app->session->get('Parametros')['EMPRESA'];
?>
<div class="site-index" style="display:flex; flex-wrap: wrap;">
    <h3></h3>
    <?php foreach(Menu::elements as $el): ?>
        <?php if (Menu::renderiza($el) && array_key_exists('href', $el) && array_key_exists('permiso', $el)): ?>
        <a class="card modulo--button" href="<?= $el['href'] ?>">
            <div class="card-body modulo--card">
                <i class="<?= $el['icon'] ?>"></i> <?= $el['name'] ?>
            </div>
        </a>
        <?php endif; ?>
    <?php endforeach; ?>
</div>
