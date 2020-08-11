<?php

namespace common\assets;

use yii\web\AssetBundle;

class ConfirmationAsset extends AssetBundle
{
    public $sourcePath = '@common';
    public $css = [
        'css/jquery-confirm.min.css'
    ];
    public $js = [
        'js/jquery-confirm.min.js'
    ];
}
