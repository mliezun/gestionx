<?php

/**
 * @link http://www.yiiframework.com/
 * @copyright Copyright (c) 2008 Yii Software LLC
 * @license http://www.yiiframework.com/license/
 */

namespace common\assets;

use yii\web\AssetBundle;

/**
 * @author Qiang Xue <qiang.xue@gmail.com>
 * @since 2.0
 */
class BowerAsset extends AssetBundle
{
    public $sourcePath = '@bower/';
    public $css = [
        'font-awesome/css/all.min.css',
        'flag-icon-css/css/flag-icon.min.css',
        'material-design-iconic-font/dist/css/material-design-iconic-font.min.css'
    ];
}
