<?php

return [
    [
        'class' => 'yii\rest\UrlRule',
        'controller' => [
            'api/suscripciones',
            'api/planes'
        ],
        'pluralize' => false
    ],
    [
        'class' => 'yii\rest\UrlRule',
        'controller' => ['api/paypal'],
        'pluralize' => false,
        'patterns' => [
            'POST webhook' => 'webhook',
            'POST' => 'create',
            '{id}' => 'options',
            '' => 'options'
        ],
    ],
    [
        'class' => 'yii\rest\UrlRule',
        'controller' => ['api/suscripciones'],
        'pluralize' => false,
        'patterns' => [
            'POST cancelar' => 'cancelar',
            'POST' => 'create',
            'GET actuales' => 'suscripciones-actuales',
            'GET esSuscripto' => 'es-usuario-suscripto',
            'OPTIONS actuales' => 'options',
            'OPTIONS esSuscripto' => 'options',
            '' => 'options',
        ],
    ]
];
