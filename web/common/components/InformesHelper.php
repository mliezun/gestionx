<?php

namespace common\components;

use Yii;
use common\helpers\StringsHelper;

class InformesHelper
{
    /**
     * Permite expandir valores a un array asociativo que contenga
     * los nombres de las columnas y los valores finales agrupados.
     *
     * @param columnas Array de strings con los nombres de las columnas
     * @param valores Array de objetos con los valores a agrupar
     * @param groupBy Clave de agrupación
     * @param reduceBy Clave con la que se genera el valor final
     * @param reduceFn String que se debe evaluar para obtener un closure PHP
     */
    private static function expandirValores(
        $columnas,
        $valores = [],
        $groupBy = null,
        $reduceBy = null,
        $reduceFn = 'function () { return null; }'
    ) {
        $out = array();
        $agrupados = NinjaArrayHelper::groupBy($valores, $groupBy);
        foreach ($columnas as $col) {
            eval('$reduceClosure = ' . $reduceFn . ';');
            $grupo = ($agrupados[$col] ?? []);
            $out[$col] = array_reduce(array_map(function ($el) use ($reduceBy) {
                return $el[$reduceBy];
            }, $grupo), $reduceClosure, $reduceClosure());
        }
        return $out;
    }


    /**
     * Expande el informe usando las columnas terminadas en:
     * JsonGroupValues y JsonGroupKeys.
     * @param informe
     */
    public static function expand($informe)
    {
        $out = array();

        /**
         * Si el informe está vacío termino el procesamiento
         */
        if (!\is_array($informe) || count($informe) === 0) {
            return $out;
        }
        
        /**
         * Array clave valor donde las claves son las entidades a expandir
         * y los valores son arrays que contienen las columnas a las que
         * se hará la expansión.
         */
        $columnas = array();
        $primeraFila = $informe[0];
        foreach ($primeraFila as $key => $val) {
            // Buscar keys que terminen en 'JsonGroupKeys'
            if (StringsHelper::endsWith($key, 'JsonGroupKeys')) {
                $columnas[str_replace($key, 'JsonGroupKeys', '')] = json_decode($val);
            }
        }

        /**
         * Si no hay elementos para expandir devuelvo el array como estaba.
         */
        if (count($columnas) === 0) {
            return NinjaArrayHelper::deepMap($informe, 'strval');
        }

        /**
         * Itero las filas del informe y voy expandiendo todas las columnas
         * que estén almacenadas en la variable $columnas.
         */
        foreach ($informe as $fila) {
            $new_fila = array();
            foreach ($fila as $key => $val) {
                if (StringsHelper::endsWith($key, 'JsonGroupValues')) {
                    $entidad = str_replace($key, 'JsonGroupValues', '');
                    $datos = json_decode($val, true);
                    $new_fila = array_merge($new_fila, self::expandirValores(
                        $columnas[$entidad],
                        $datos['Values'] ?? [],
                        $datos['GroupBy'] ?? null,
                        $datos['ReduceBy'] ?? null,
                        $datos['ReduceFn'] ?? 'function () { return null; }'
                    ));
                } elseif (!StringsHelper::endsWith($key, 'JsonGroupKeys')) {
                    $new_fila[$key] = $val;
                }
            }
            $out[] = $new_fila;
        }

        return NinjaArrayHelper::deepMap($out, 'strval');
    }
}
