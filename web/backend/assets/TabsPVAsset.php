<?php

namespace backend\assets;

use yii\web\AssetBundle;

class TabsPVAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    public $css = [
    ];
    public $js = [
        'scripts/TabsPV.js'
    ];
    public $depends = [
    ];
}
