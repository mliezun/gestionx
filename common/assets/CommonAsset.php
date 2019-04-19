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
        'js/Main.js'
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
