<?php

namespace common\components;

use Yii;
use yii\web\HttpException;

class PermisosHelper
{

    /**
     * Guarda el array de permisos en la sesión.
     *
     * @param array $permisos
     */
    public static function guardarPermisosSesion(array $permisos)
    {
        Yii::$app->session->set('Permisos', $permisos);
    }

    /**
     * Verifica si el usuario tiene el permiso. Tira excepción en caso contrario.
     *
     * @param string $permiso Permiso a verificar
     * @throws HttpException Si no no tiene permiso
     */
    public static function verificarPermiso(string $permiso)
    {
        if (!self::tienePermiso($permiso)) {
            self::tirarExcepcion();
        }
    }

    /**
     * Verifica si el usuario tiene alguno de los permisos. Tira excepción en caso contrario.
     *
     * @param array $permisos Lista de permisos
     * @throws HttpException Si no no tiene algún permiso
     */
    public static function verificarAlgunPermiso(array $permisos)
    {
        if (!self::tieneAlgunPermiso($permisos)) {
            self::tirarExcepcion();
        }
    }

    /**
     * Verifica si el usuario tiene todos los permisos de la lista. Tira excepción en caso contrario.
     *
     * @param array $permisos Lista de permisos
     * @throws HttpException Si no no tiene todos los permisos
     */
    public static function verificarTodosPermisos(array $permisos)
    {
        if (!self::tieneTodosPermisos($permisos)) {
            self::tirarExcepcion();
        }
    }

    /**
     * Retorna si el usuario tiene el permiso.
     *
     * @param string $permiso
     * @return bool Tiene permiso
     */
    public static function tienePermiso(string $permiso): bool
    {
        return in_array($permiso, Yii::$app->session->get('Permisos'));
    }

    /**
     * Retorna si el usuario tiene alguno de los permisos.
     *
     * @param array $permisos Lista de permisos
     * @return bool Tiene alguno de los permisos
     */
    public static function tieneAlgunPermiso(array $permisos): bool
    {
        foreach ($permisos as $permiso) {
            if (self::tienePermiso($permiso)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Retorna si el usuario tiene todos los permisos.
     *
     * @param array $permisos
     * @return bool Tiene todos los permisos
     */
    public static function tieneTodosPermisos(array $permisos): bool
    {
        foreach ($permisos as $permiso) {
            if (!self::tienePermiso($permiso)) {
                return false;
            }
        }

        return true;
    }

    private static function tirarExcepcion()
    {
        throw new HttpException('403', 'No se tienen los permisos necesarios para ver la página solicitada.');
    }
}
