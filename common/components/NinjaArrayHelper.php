<?php

namespace common\components;

use Yii;

class NinjaArrayHelper
{
    public static function normalizar($datos, $normalizacion)
    {
        if (gettype($datos) !== 'array') {
            return $datos;
        }
        $out = [];
        foreach ($datos as $clave => $valor) {
            if (array_key_exists($clave, $normalizacion)) {
                $clave = $normalizacion[$clave];
                if (gettype($clave) === 'array') {
                    $first_key = array_key_first($valor);
                    if (isset($first_key) && gettype($valor[$first_key]) === 'array') {
                        $nuevoValor = [];
                        foreach ($valor as $v) {
                            $nuevoValor[] = self::normalizar($v, $clave[1]);
                        }
                        $valor = $nuevoValor;
                    } else {
                        $valor = self::normalizar($valor, $clave[1]);
                    }
                    $clave = $clave[0];
                }
                $out[$clave] = $valor;
            }
        }
        return $out;
    }

    public static function assocToArray($arrayAssoc)
    {
        $out = [];
        foreach($arrayAssoc as $key => $val) {
            $out[] = [
                $key => $val
            ];
        }
        return $out;
    }

    public static function renameKeys($array, $rename, $remove = true)
    {
        $out = [];
        foreach($array as $el) {
            $newEl = [];
            foreach ($rename as $orgKey => $newKey) {
                if (array_key_exists($orgKey, $el)) {
                    $newEl[$newKey] = $el[$orgKey];
                } else if (!$remove) {
                    $newEl[$orgKey] = $el[$orgKey];
                }
            }
            $out[] = $newEl;
        }
        return $out;
    }
}
