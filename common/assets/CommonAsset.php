<?php

namespace common\assets;

use yii\web\AssetBundle;

/**
 * Main backend application asset bundle.
 */
class CommonAsset extends AssetBundle
{
    public $sourcePath = '@common';
    public $css = [
    ];
    public $js = [
    ];
    public $depends = [
        'common\assets\BowerAsset',
        'yii\widgets\MaskedInputAsset',
        'yii\web\YiiAsset',
        'yii\bootstrap4\BootstrapAsset',
    ];
}
