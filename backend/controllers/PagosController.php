<?php

namespace backend\controllers;

use common\models\Ventas;
use common\models\Pagos;
use common\models\PuntosVenta;
use common\models\GestorVentas;
use common\models\GestorRemitos;
use common\models\GestorClientes;
use common\models\forms\BuscarForm;
use common\models\forms\LineasForm;
use common\components\PermisosHelper;
use common\components\AfipHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;
use yii\helpers\Url;

class PagosController extends BaseController
{
    public function actionIndex($id)
    {
        PermisosHelper::verificarPermiso('PagarVenta');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $venta = new Ventas();
        $venta->IdVenta = $id;

        $venta->Dame();

        $pagos = $venta->DamePagos();

        $pv = new PuntosVenta();
        $pv->IdPuntoVenta = $venta->IdPuntoVenta;
        $pv->Dame();
        $anterior = [
            'label' => "Punto de Venta: " . $pv->PuntoVenta,
            'link' => Url::to(['/puntos-venta/operaciones', 'id' => $venta->IdPuntoVenta])
        ];
        $titulo = 'Pagos de la Venta ' . $id;

        $paginado->totalCount = count($pagos);
        $pagos = array_slice($pagos, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'model' => $venta,
            'pagos' => $pagos,
            'anterior' => $anterior,
            'titulo' => $titulo,
            'busqueda' => $busqueda
        ]);
    }
    
    public function actionAlta($id)
    {
        PermisosHelper::verificarPermiso('PagarVenta');

        $venta = new Ventas();
        $venta->IdVenta = $id;
        $venta->Dame();

        $pago = new Pagos();
        $remitos=0;

        switch (Yii::$app->request->get('Tipo')) {
            case 'T':
                PermisosHelper::verificarPermiso('PagarVentaTarjeta');
                $pago->setScenario(Pagos::_ALTA_TARJETA);
                $pago->IdMedioPago = 3;
                break;
            case 'E':
                PermisosHelper::verificarPermiso('PagarVentaEfectivo');
                $pago->setScenario(Pagos::_ALTA_EFECTIVO);
                $pago->IdMedioPago = 1;
                break;
            case 'M':
                PermisosHelper::verificarPermiso('PagarVentaMercaderia');
                $pago->setScenario(Pagos::_ALTA_MERCADERIA);
                $pago->IdMedioPago = 2;
                $remitos = (new GestorRemitos())->Buscar(0,'','A',0);
                break;
            case 'C':
                PermisosHelper::verificarPermiso('PagarVentaCheque');
                $pago->setScenario(Pagos::_ALTA_CHEQUE);
                $pago->IdMedioPago = 5;
                break;
        }

        if($pago->load(Yii::$app->request->post())){
            switch (Yii::$app->request->get('Tipo')) {
                case 'T':
                    $resultado = $venta->PagarTarjeta($pago);
                    break;
                case 'E':
                    $resultado = $venta->PagarEfectivo($pago);
                    break;
                case 'M':
                    $resultado = $venta->PagarMercaderia($pago);
                    break;
                case 'C':
                    $resultado = $venta->PagarCheque($pago);
                    break;
            }

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            return $this->renderAjax('alta', [
                'titulo' => 'Agregar pago',
                'model' => $pago,
                'remitos' => $remitos
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarVenta');
        
        $venta = new Ventas();

        $venta->setScenario(Ventas::_MODIFICAR);

        if ($venta->load(Yii::$app->request->post()) && $venta->validate()) {
            $gestor = new GestorVentas();
            $resultado = $gestor->Modificar($venta);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $venta->IdVenta = $id;
            
            $venta->Dame();

            return $this->renderAjax('alta', [
                        'titulo' => 'Editar Venta',
                        'model' => $venta
            ]);
        }
    }

    public function actionAgregarPago($id)
    {
        PermisosHelper::verificarPermiso('PagarVenta');
        Yii::$app->response->format = 'json';

        $venta = new Ventas();
        $venta->IdVenta = $id;

        $pago = new Pagos();

        switch (Yii::$app->request->get('Tipo')) {
            case 'T':
                $pago->setScenario(Pagos::_ALTA_TARJETA);
                $pago->IdMedioPago = 3;
                break;
            case 'E':
                $pago->setScenario(Pagos::_ALTA_EFECTIVO);
                $pago->IdMedioPago = 1;
                break;
        }

        if($pago->load(Yii::$app->request->post()) && $pago->validate()){
            $resultado = $venta->Pagar($pago);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            return $this->renderAjax('@app/views/pagos/alta', [
                'titulo' => 'Agregar pago',
                'model' => $pago
            ]);
        }
    }

    public function actionPagos($id)
    {
        $venta = new Ventas();

        $venta->IdVenta = $id;

        $venta->Dame();

        $pagos = $venta->DamePagos();

        $pv = new PuntosVenta();
        $pv->IdPuntoVenta = $venta->IdPuntoVenta;
        $pv->Dame();
        $anterior = [
            'label' => "Punto de Venta: " . $pv->PuntoVenta,
            'link' => Url::to(['/puntos-venta/operaciones', 'id' => $venta->IdPuntoVenta])
        ];
        $titulo = 'Pagos de la Venta ' . $id;
        $urlBase = '/ventas/pagos';
        $busqueda = new BuscarForm();

        return $this->render('@app/views/pagos/index', [
            'model' => $venta,
            'pagos' => $pagos,
            'anterior' => $anterior,
            'titulo' => $titulo,
            'urlBase' => $urlBase,
            'busqueda' => $busqueda
        ]);
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaVenta');

        Yii::$app->response->format = 'json';
        
        $venta = new Ventas();
        $venta->IdVenta = $id;

        $resultado = $venta->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDevolucion($id)
    {
        PermisosHelper::verificarPermiso('DevolucionVenta');

        Yii::$app->response->format = 'json';
        
        $venta = new Ventas();
        $venta->IdVenta = $id;

        $resultado = $venta->Devolucion();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionLineas($id)
    {
        $venta = new Ventas();

        $venta->IdVenta = $id;

        $venta->Dame();

        $lineas = $venta->DameLineas();

        $pv = new PuntosVenta();
        $pv->IdPuntoVenta = $venta->IdPuntoVenta;
        $pv->Dame();
        $anterior = [
            'label' => "Punto de Venta: " . $pv->PuntoVenta,
            'link' => Url::to(['/puntos-venta/operaciones', 'id' => $venta->IdPuntoVenta])
        ];
        $titulo = 'Venta ' . $id;
        $urlBase = '/ventas';

        return $this->render('@app/views/lineas/index', [
            'model' => $venta,
            'lineas' => $lineas,
            'anterior' => $anterior,
            'titulo' => $titulo,
            'urlBase' => $urlBase,
            'tipoPrecio' => 'PrecioVenta'
        ]);
    }

    public function actionAgregarLinea($id)
    {
        PermisosHelper::verificarPermiso('AltaLineaVenta');
        Yii::$app->response->format = 'json';

        $venta = new Ventas();

        $venta->IdVenta = $id;

        $linea = new LineasForm();

        if ($linea->load(Yii::$app->request->post()) && $linea->validate(null, false)) {
            $resultado = $venta->AgregarLinea($linea);
        } else {
            $resultado = implode(' ', $linea->getErrorSummary(false));
            if (trim($resultado) == '') {
                $resultado = "Los valores indicados no son correctos.";
            }
        }

        if (substr($resultado, 0, 2) != 'OK') {
            return ['error' => $resultado];
        }

        return ['error' => null];
    }

    public function actionQuitarLinea($id)
    {
        PermisosHelper::verificarPermiso('BorrarLineaVenta');
        Yii::$app->response->format = 'json';

        $venta = new Ventas();

        $venta->IdVenta = $id;

        $resultado = $venta->QuitarLinea(Yii::$app->request->post('IdArticulo'));

        if (substr($resultado, 0, 2) != 'OK') {
            return ['error' => $resultado];
        }

        return ['error' => null];
    }
}

?>