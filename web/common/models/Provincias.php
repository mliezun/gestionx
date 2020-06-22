<?php

namespace common\models;

class Provincias
{
    const PROVINCIAS = [
        ['Buenos Aires', 'PBA', 'AR-B'],
        ['Catamarca', 'CA', 'AR-K'],
        ['Chaco', 'CH', 'AR-H'],
        ['Chubut', 'CT', 'AR-U'],
        ['Córdoba', 'CB', 'AR-X'],
        ['Corrientes', 'CR', 'AR-W'],
        ['Entre Ríos', 'ER', 'AR-E'],
        ['Formosa', 'FO', 'AR-P'],
        ['Jujuy', 'JY', 'AR-Y'],
        ['La Pampa', 'LP', 'AR-L'],
        ['La Rioja', 'LR', 'AR-F'],
        ['Mendoza', 'MZ', 'AR-M'],
        ['Misiones', 'MI', 'AR-N'],
        ['Neuquén', 'NQ', 'AR-Q'],
        ['Río Negro', 'RN', 'AR-R'],
        ['Salta', 'SA', 'AR-A'],
        ['San Juan', 'SJ', 'AR-J'],
        ['San Luis', 'SL', 'AR-D'],
        ['Santa Cruz', 'SC', 'AR-Z'],
        ['Santa Fe', 'SF', 'AR-S'],
        ['Santiago del Estero', 'SE', 'AR-G'],
        ['Tierra del Fuego, Antártida e Islas del Atlántico Sur', 'TF', 'AR-V'],
        ['Tucumán', 'TU', 'AR-T']
    ];

    const COLUMNAS = ['Nombre' => 0, 'Abreviatura' => 1, 'ISO 3166-2' => 3];

    /**
     * Permite obtener los nombres de todas las provincias.
     */
    public static function Nombres()
    {
        return array_map(function ($provincia) {
            return $provincia[self::COLUMNAS['Nombre']];
        }, self::PROVINCIAS);
    }

    /**
     * Permite listar las provincias de manera que las claves y los valores
     * del listado son el nombre de la provincia.
     */
    public static function Provincias()
    {
        $out = array();
        foreach (self::PROVINCIAS as $provincia) {
            $out[$provincia[self::COLUMNAS['Nombre']]] = $provincia[self::COLUMNAS['Nombre']];
        }
        return $out;
    }

    /**
     * Permite obtener una provincia si es que existe.
     */
    public static function Dame($Provincia)
    {
        $provincias = self::Provincias();
        if (array_key_exists($Provincia, $provincias)) {
            return $provincias[$Provincia];
        }
        return '';
    }
}
