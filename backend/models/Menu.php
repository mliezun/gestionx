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
            'name' => 'Cheques',
            'icon' => 'fas fa-money-check',
            'href' => '/cheques',
            'permiso' => 'BuscarCheques'
        ],
        [
            'name' => 'Sistema',
            'icon' => 'fas fa-cogs',
            'submenu' => [
                [
                    'name' => 'Roles',
                    'href' => '/roles',
                    'permiso' => 'BuscarRoles'
                ],
                [
                    'name' => 'Bancos',
                    'href' => '/bancos',
                    'permiso' => 'BuscarBancos'
                ],
                [
                    'name' => 'Listas de Precio',
                    'icon' => 'fas fa-list-alt',
                    'href' => '/listas-precio',
                    'permiso' => 'BuscarListasPrecio'
                ],
                [
                    'name' => 'Canales',
                    'icon' => 'fas fa-sliders-h',
                    'href' => '/canales',
                    'permiso' => 'BuscarCanales'
                ],
                [
                    'name' => 'Destinos de cheques',
                    'href' => '/destinos-cheque',
                    'permiso' => 'BuscarDestinosCheque'
                ],
                [
                    'name' => 'Parámetros',
                    'href' => '/empresa',
                    'permiso' => 'BuscarParametro'
                ],
                [
                    'name' => 'Empresas',
                    'href' => '/empresas',
                    'permiso' => 'BuscarEmpresas'
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
            return PermisosHelper::algunPermisoContiene($el['permiso']);
        }
        if (array_key_exists('submenu', $el)) {
            return PermisosHelper::tieneAlgunPermiso(ArrayHelper::map($el['submenu'], 'permiso', 'permiso'));
        }
        return true;
    }
}