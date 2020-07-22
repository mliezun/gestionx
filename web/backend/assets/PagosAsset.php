<?php

namespace backend\assets;

use yii\web\AssetBundle;

class PagosAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    public $css = [
    ];
    public $js = [
        'scripts/Pagos.js'
    ];
    public $depends = [
    ];
}
