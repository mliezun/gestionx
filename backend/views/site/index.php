<?php

use backend\models\Menu;

/* @var $this yii\web\View */

$this->title = 'Módulos del sistema ' . Yii::$app->session->get('Parametros')['EMPRESA'];
?>
<div class="site-index" style="display:flex;">
    <h3></h3>
    <?php foreach(Menu::elements as $el): ?>
        <?php if (Menu::renderiza($el) && array_key_exists('href', $el) && array_key_exists('permiso', $el)): ?>
        <div class="card">
            <div class="card-body">
                <a href="<?= $el['href'] ?>"><i class="<?= $el['icon'] ?>"></i> <?= $el['name'] ?></a>
            </div>
        </div>
        <?php endif; ?>
    <?php endforeach; ?>
</div>
