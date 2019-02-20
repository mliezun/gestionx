<?php

namespace backend\assets;

use yii\web\AssetBundle;

/**
 * Admin backend application asset bundle.
 */
class AdmAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    public $css = [
        'css/admin.css',
        'fonts/circular-std/style.css'
    ];
    public $js = [
    ];
    public $depends = [
        'backend\assets\AppAsset',
        'yii\bootstrap4\BootstrapPluginAsset',
        'phpnt\slimscroll\SlimScrollAsset',
        'common\assets\BowerAsset',
    ];
}
