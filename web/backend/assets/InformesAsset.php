<?php

namespace backend\assets;

use yii\web\AssetBundle;

class InformesAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    public $css = [
    ];
    public $js = [
        'scripts/Informes.js',
    ];
    public $depends = [
        'backend\assets\AppAsset'
    ];
}
