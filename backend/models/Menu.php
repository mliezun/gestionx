<?php

namespace backend\models;

use common\components\PermisosHelper;
use yii\helpers\ArrayHelper;

class Menu
{
    const elements = [
        [
            'name' => 'Inicio',
            'icon' => 'fas fa-home',
            'href' => '/'
        ],
        [
            'name' => 'Usuarios',
            'icon' => 'fas fa-users',
            'href' => '/usuarios',
            'permiso' => 'BuscarUsuarios'
        ],
        [
            'name' => 'Roles',
            'icon' => 'fas fa-user-tag', 
            'href' => '/roles',
            'permiso' => 'BuscarRoles'
        ],
        [
            'name' => 'Puntos de Venta',
            'icon' => 'far fa-building',
            'href' => '/puntos-venta',
            'permiso' => 'BuscarPuntosVenta'
        ],
        [
            'name' => 'Proveedores',
            'icon' => 'fas fa-store',
            'href' => '/proveedores',
            'permiso' => 'BuscarProveedores'
        ],
        [
            'name' => 'Articulos',
            'icon' => 'fas fa-tag',
            'href' => '/articulos',
            'permiso' => 'BuscarArticulos'
        ],
        [
            'name' => 'Clientes',
            'icon' => 'far fa-id-badge',
            'href' => '/clientes',
            'permiso' => 'BuscarClientes'
        ],
        [
            'name' => 'Sistema',
            'icon' => 'fas fa-cogs',
            'submenu' => [
                [
                    'name' => 'Parámetros',
                    'href' => '/empresa',
                    'permiso' => 'BuscarParametro'
                ]
            ]
        ],
    ];

    /**
     * renderiza indica si el elemento se debe renderizar o no.
     */
    public static function renderiza($el)
    {
        if (array_key_exists('permiso', $el)) {
            return PermisosHelper::tienePermiso($el['permiso']);
        }
        if (array_key_exists('submenu', $el)) {
            return PermisosHelper::tieneAlgunPermiso(ArrayHelper::map($el['submenu'], 'permiso', 'permiso'));
        }
        return true;
    }
}