<?php

namespace common\assets;

use yii\web\AssetBundle;

/**
 * Main backend application asset bundle.
 */
class CommonAsset extends AssetBundle
{
    public $sourcePath = '@common';
    public $js = [
        'js/Main.js',
        'js/VueDirectives.js',
        'js/VueSelect.min.js'
    ];
    public $css = [
        'css/app.css',
        'css/VueSelect.min.css'
    ];
    public $depends = [
        'common\assets\PaceAsset',
        'yii\widgets\MaskedInputAsset',
        'yii\web\YiiAsset',
        'yii\bootstrap4\BootstrapAsset',
        'yii\bootstrap4\BootstrapPluginAsset',
        'common\assets\BowerAsset',
    ];
}
