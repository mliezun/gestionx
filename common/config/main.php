<?php
return [
    'timeZone' => 'America/Argentina/Tucuman',
    'language' => 'es',
    'vendorPath' => dirname(dirname(__DIR__)) . '/vendor',
    'aliases' => [
        '@bower' => '@vendor/bower-asset',
        '@npm'   => '@vendor/npm-asset',
    ],
    'components' => [
        'assetManager' => [
            'linkAssets' => true,
            'appendTimestamp' => true,
        ],
        'jwt' => [
            'class' => 'sizeg\jwt\Jwt',
            'key'   => '7Tb\\I85HJgfhZ10WcDVD$)ppjz>-59}6.',
        ],
        'cache' => [
            'class' => 'yii\redis\Cache',
        ],
        'session' => [
            'class' => 'yii\redis\Session',
        ],
        'redis' => [
            'class' => 'yii\redis\Connection',
            'hostname' => 'localhost',
            'port' => 6379,
            'database' => 0,
        ],
        'formatter' => [
            'defaultTimeZone' => 'America/Argentina/Tucuman',
            'dateFormat' => 'dd/MM/yyyy',
            'datetimeFormat' => 'dd/MM/yyyy H:mm',
            'decimalSeparator' => ',',
            'thousandSeparator' => '.',
            'locale' => 'es-AR'
        ],
    ],
];
