<?php

namespace common\assets;

use yii\web\AssetBundle;

class PaceAsset extends AssetBundle
{
    public $sourcePath = '@common';
    public $css = [
        'css/pace.css'
    ];
    public $js = [
        'js/pace.min.js'
    ];
}
