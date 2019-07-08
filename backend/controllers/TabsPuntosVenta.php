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
use Yii;

class TabsPuntosVenta extends Controller
{
    private $IdPuntoVenta;


    private function tabs()
    {
        return [
            [
                'Permiso' => 'AltaVenta',
                'Nombre' => 'Ventas',
                'Render' => function () {
                    return $this->Ventas();
                }
            ],
            [
                'Permiso' => 'AltaRemito',
                'Nombre' => 'Remitos',
                'Render' => function () {
                    return $this->Remitos();
                }
            ]
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

    public function Contenido()
    {
        return $this->renderPartial('tab-content', [
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
            $estado = $busqueda->Combo2 ? $busqueda->Combo2 : 'T';
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

    public function Ventas()
    {
        return '';
    }
}
