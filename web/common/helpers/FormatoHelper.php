<?php

namespace common\helpers;

class FormatoHelper
{
    const FORMATO_MONTO = [
        'decimals' => 2,
        'dec_point' => ',',
        'thousands_sep' => '.'
    ];

    public static function formatearMonto($monto)
    {
        return number_format(
            $monto,
            self::FORMATO_MONTO['decimals'],
            self::FORMATO_MONTO['dec_point'],
            self::FORMATO_MONTO['thousands_sep'],
        );
    }
}
