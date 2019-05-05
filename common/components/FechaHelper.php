<?php
namespace common\components;

use InvalidArgumentException;
use Yii;

class FechaHelper
{
    /**
     * Fecha actual en formato Mysql
     *
     * @return string fecha
     */
    public static function dateActualMysql(): string
    {
        return date('Y-m-d');
    }

    /**
     * Fecha actual en formato día/mes/año
     *
     * @return string fecha
     */
    public static function dateActualLocal(): string
    {
        $fechaMysql = self::dateActualMysql();
        return self::formatearDateLocal($fechaMysql);
    }

    /**
     * Fecha y hora actual en formato Mysql
     *
     * @param boolean $incluyeSegundos
     * @return string
     */
    public static function datetimeActualMysql(bool $incluyeSegundos = false): string
    {
        return date("Y-m-d H:i:s");
    }
    
    /**
     * Fecha y hora actual en formato día/mes/año Horas:Minutos[:Segundos]
     *
     * @param boolean $incluyeSegundos falso por defecto
     * @return string fecha
     */
    public static function datetimeActualLocal(bool $incluyeSegundos = false): string
    {
        return date(self::formatoSalidaDatetimeLocal($incluyeSegundos));
    }

    /**
     * Permite formatear una fecha en el formato día/mes/año al utilizado por MySQL
     *
     * @param string $fecha Fecha en formato día/mes/año
     * @return string Fecha en formato Date de MySQL
     * @throws InvalidArgumentException si la fecha es inválida
     */
    public static function formatearDateMysql($fecha)
    {
        if ($fecha == null || $fecha == '') {
            return null;
        }

        $unixTimestamp = self::fechaATimestamp($fecha);

        if (!$unixTimestamp) {
            throw new InvalidArgumentException("La fecha {$fecha} es inválida.");
        }

        return date("Y-m-d", $unixTimestamp);
    }

    /**
     * Permite formatear una fecha y hora en el formato día/mes/año al utilizado por MySQL.
     *
     * @param string $fecha Fecha en formato día/mes/año Horas:Minutos:Segundos
     * @return string Fecha en formato Datetime de MySQL
     * @throws InvalidArgumentException si la fecha es inválida
     */
    public static function formatearDatetimeMysql($fecha)
    {
        if ($fecha == null || $fecha == '') {
            return null;
        }

        $unixTimestamp = self::fechaATimestamp($fecha);

        if (!$unixTimestamp) {
            throw new InvalidArgumentException("La fecha {$fecha} es inválida.");
        }

        return date("Y-m-d H:i:s", $unixTimestamp);
    }

    /**
     * Permite formatear una fecha en el formato MySQL al formato día/mes/año
     *
     * @param string $fecha Fecha en formato MySQL
     * @return string Fecha en formato día/mes/año
     */
    public static function formatearDateLocal($fecha)
    {
        if ($fecha == null || $fecha == '') {
            return null;
        }

        return Yii::$app->formatter->asDate($fecha);
    }

    /**
      * Permite formatear una fecha y hora en el formato MySQL al formato día/mes/año
      *
      * @param string $fecha Fecha en formato MySQL
      * @param bool $incluyeSegundos Incluír segundos en la salida. False por defecto.
      * @return string Fecha en formato día/mes/año Horas:Minutos[:Segundos]
      */
    public static function formatearDatetimeLocal($fecha, $incluyeSegundos = false)
    {
        if ($fecha == null || $fecha == '') {
            return null;
        }

        $formatoSalida = self::formatoSalidaDatetimeLocal($incluyeSegundos);
        return date($formatoSalida, strtotime($fecha));
    }

    private static function formatoSalidaDatetimeLocal(bool $incluyeSegundos): string
    {
        return $incluyeSegundos ? 'd/m/Y H:i:s': 'd/m/Y H:i';
    }

    private static function fechaATimestamp($fecha)
    {
        return strtotime(str_replace('/', '-', $fecha));
    }
}
