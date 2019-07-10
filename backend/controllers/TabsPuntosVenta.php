<?php

namespace backend\controllers;

use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;
use common\models\PuntosVenta;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use common\models\GestorProveedores;
use common\models\GestorRemitos;
use common\models\GestorRoles;
use common\models\GestorClientes;
use common\models\Ventas;
use common\models\GestorVentas;
use Yii;

class TabsPuntosVenta extends BaseController
{
    private $IdPuntoVenta;


    private function tabs()
    {
        return [
            [
                'Permiso' => 'BuscarVentas',
                'Nombre' => 'Ventas',
                'Render' => function () {
                    return $this->Ventas();
                }
            ],
            [
                'Permiso' => 'BuscarRemitos',
                'Nombre' => 'Remitos',
                'Render' => function () {
                    return $this->Remitos();
                }
            ],
            [
                'Permiso' => 'BuscarUsuariosPuntoVenta',
                'Nombre' => 'Usuarios',
                'Render' => function () {
                    return $this->Usuarios();
                }
            ],
        ];
    }

    public function __construct($IdPuntoVenta)
    {
        $this->IdPuntoVenta = $IdPuntoVenta;
    }
    
    public function renderPartial($view, $options = [])
    {
        return parent::renderPartial('@app/views/puntos-venta/tabs/' . $view, $options);
    }

    public function Lista()
    {
        return $this->renderPartial('tablist', [
            'tabs' => $this->tabs()
        ]);
    }

    public function Remitos()
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorRemitos();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Combo2 ? $busqueda->Combo2 : 'E';
            $proveedor = $busqueda->Combo ? $busqueda->Combo : 0;
            $remitos = $gestor->Buscar(0,$busqueda->Cadena, $estado, $proveedor);
        } else {
            $remitos = $gestor->Buscar(0);
        }

        $paginado->totalCount = count($remitos);
        $remitos = array_slice($remitos, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        $gestorProv = new GestorProveedores();
        $proveedores = $gestorProv->Buscar();

        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $this->IdPuntoVenta;
        $puntoventa->Dame();

        return $this->renderPartial('remitos', [
            'models' => $remitos,
            'busqueda' => $busqueda,
            'proveedores' => $proveedores,
            'puntoventa' => $puntoventa
        ]);
    }

    public function Usuarios()
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();


        $pv = new PuntosVenta();

        $pv->IdPuntoVenta = $this->IdPuntoVenta;

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $usuarios = $pv->BuscarUsuarios($busqueda->Cadena);
        } else {
            $usuarios = $pv->BuscarUsuarios();
        }

        $paginado->totalCount = count($usuarios);
        $usuarios = array_slice($usuarios, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $this->IdPuntoVenta;
        $puntoventa->Dame();
        
        return $this->renderPartial('usuarios', [
            'models' => $usuarios,
            'busqueda' => $busqueda,
            'puntoventa' => $puntoventa
        ]);
    }

    public function Ventas()
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorVentas();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $FechaDesde = $busqueda->FechaInicio;
            $FechaFin = $busqueda->FechaFin;
            $Cliente = $busqueda->Combo ? $busqueda->Combo : 0;
            $Estado = $busqueda->Combo2 ? $busqueda->Combo2 : 'E';
            $Tipo = $busqueda->Combo3 ? $busqueda->Combo3 : 'T';
            $ventas = $gestor->Buscar($this->IdPuntoVenta, $FechaDesde, $FechaFin, $Cliente, $Estado, $Tipo);
        } else {
            $ventas = $gestor->Buscar($this->IdPuntoVenta);
        }

        $paginado->totalCount = count($ventas);
        $ventas = array_slice($ventas, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        $puntoventa = new PuntosVenta();
        $puntoventa->IdPuntoVenta = $this->IdPuntoVenta;
        $puntoventa->Dame();

        $gclientes = new GestorClientes();
        $clientes = $gclientes->Listar();
        
        return $this->renderPartial('ventas', [
            'models' => $ventas,
            'busqueda' => $busqueda,
            'puntoventa' => $puntoventa,
            'clientes' => $clientes
        ]);
    }
}
