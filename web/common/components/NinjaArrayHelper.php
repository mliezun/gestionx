<?php

namespace common\components;

use Yii;

class NinjaArrayHelper
{
    /**
     * Normalizar permite cambiar el formato de un array dado según una
     * estructura de normalización.
     * @param datos
     * @param normalizacion
     */
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

    /**
     * Permite convertir un array asociativo a un array
     * de arrays asociativos con 1 clave.
     * @param arrayAssoc
     */
    public static function assocToArray($arrayAssoc)
    {
        $out = array();
        foreach ($arrayAssoc as $key => $val) {
            $out[] = [
                $key => $val
            ];
        }
        return $out;
    }

    /**
     * Renombra las keys de un array.
     * @param array
     * @param rename Rename keys - Example: ['keyA' => 'keyB']
     * @param remove Indicates if the old key is removed
     */
    public static function renameKeys($array, $rename, $remove = true)
    {
        $out = [];
        foreach ($array as $el) {
            $newEl = [];
            foreach ($rename as $orgKey => $newKey) {
                if (array_key_exists($orgKey, $el)) {
                    $newEl[$newKey] = $el[$orgKey];
                } elseif (!$remove) {
                    $newEl[$orgKey] = $el[$orgKey];
                }
            }
            $out[] = $newEl;
        }
        return $out;
    }

    /**
     * Agrupa elementos de un array por la clave indicada.
     * @param array
     * @param key Clave de agrupación
     */
    public static function groupBy($array, $key)
    {
        $out = array();
        foreach ($array as $el) {
            if (!array_key_exists($el[$key], $out)) {
                $out[$el[$key]] = array();
            }
            $out[$el[$key]][] = $el;
        }
        return $out;
    }

    /**
     * Misma funcionalidad que map, pero si un elemento es un
     * array se aplica la funcion de mapeo sobre él.
     *
     * @param array
     * @param mapFn
     */
    public static function deepMap($array, $mapFn)
    {
        $out = array();
        foreach ($array as $key => $val) {
            if (gettype($val) === 'array') {
                $out[$key] = self::deepMap($val, $mapFn);
            } else {
                $out[$key] = $mapFn($val);
            }
        }
        return $out;
    }
}
