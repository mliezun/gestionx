<?php

namespace frontend\assets;

use yii\web\AssetBundle;

class GestionxAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    public $css = [
    ];
    public $js = [
        'scripts/Gestionx.js'
    ];
    public $depends = [
        'common\assets\BowerAsset',
        'macgyer\yii2materializecss\assets\MaterializeAsset'
    ];
}
