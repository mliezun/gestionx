<?php

namespace common\assets;

use yii\web\AssetBundle;

class TableAsset extends AssetBundle
{
    public $sourcePath = '@common';
    public $css = [];
    public $js = [
        'js/jquery.stickytableheaders.min.js'
    ];
}
