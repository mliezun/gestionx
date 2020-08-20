<?php

namespace backend\assets;

use yii\web\AssetBundle;

class ArticulosAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    public $css = [
    ];
    public $js = [
        'scripts/Articulos.js',
    ];
    public $depends = [
        'backend\assets\AppAsset'
    ];
}
