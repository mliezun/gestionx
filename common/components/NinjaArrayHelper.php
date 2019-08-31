<?php

namespace common\components;

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
                    if (gettype($valor[$first_key]) === 'array') {
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
}
