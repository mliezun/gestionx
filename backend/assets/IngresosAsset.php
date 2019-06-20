<?php

namespace backend\assets;

use yii\web\AssetBundle;

class IngresosAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    public $css = [
    ];
    public $js = [
        'scripts/AltaLineas.js'
    ];
    public $depends = [
    ];
}
