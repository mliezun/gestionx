<?php

namespace backend\controllers;

use common\models\Ventas;
use common\models\Clientes;
use common\models\Pagos;
use common\models\Remitos;
use common\models\Cheques;
use common\models\PuntosVenta;
use common\models\GestorVentas;
use common\models\GestorRemitos;
use common\models\GestorClientes;
use common\models\GestorCheques;
use common\models\forms\BuscarForm;
use common\models\forms\LineasForm;
use common\components\PermisosHelper;
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
        $parcial = new BuscarForm();

        $venta = new Ventas();
        $venta->IdVenta = $id;
        $venta->Dame();

        $cliente = new Clientes();
        $cliente->IdCliente = $venta->IdCliente;
        $cliente->Dame();

        $pagos = $venta->DamePagos();

        $pv = new PuntosVenta();
        $pv->IdPuntoVenta = $venta->IdPuntoVenta;
        $pv->Dame();
        $anterior = [
            'label' => "Punto de Venta: " . $pv->PuntoVenta,
            'link' => Url::to(['/puntos-venta/operaciones', 'id' => $venta->IdPuntoVenta])
        ];
        $titulo = "Pagos de la Venta #$id - Cliente: {$cliente->getNombre()}" . ($cliente->Observaciones ? " [{$cliente->Observaciones}]" : '');

        $paginado->totalCount = count($pagos);
        $pagos = array_slice($pagos, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'model' => $venta,
            'pagos' => $pagos,
            'anterior' => $anterior,
            'titulo' => $titulo,
            'busqueda' => $busqueda,
            'parcial' => $parcial
        ]);
    }
    
    public function actionAlta($id)
    {
        PermisosHelper::verificarPermiso('PagarVenta');

        $venta = new Ventas();
        $venta->IdVenta = $id;

        $pago = new Pagos();
        $remitos=0;
        $cheques=0;

        switch (Yii::$app->request->get('Tipo')) {
            case 'T':
                PermisosHelper::verificarPermiso('PagarVentaTarjeta');
                $pago->setScenario(Pagos::_ALTA_TARJETA);
                $pago->MedioPago = 'Tarjeta';
                break;
            case 'E':
                PermisosHelper::verificarPermiso('PagarVentaEfectivo');
                $pago->setScenario(Pagos::_ALTA_EFECTIVO);
                $pago->MedioPago = 'Efectivo';
                break;
            case 'M':
                PermisosHelper::verificarPermiso('PagarVentaMercaderia');
                $pago->setScenario(Pagos::_ALTA_MERCADERIA);
                $pago->MedioPago = 'Mercaderia';
                $remitos = (new GestorRemitos())->Buscar($venta->IdPuntoVenta,'','A',0,'N');
                break;
            case 'C':
                PermisosHelper::verificarPermiso('PagarVentaCheque');
                $pago->setScenario(Pagos::_ALTA_CHEQUE);
                $pago->MedioPago = 'Cheque';
                $cheques = (new GestorCheques())->Buscar();
                break;
        }
        $pago->DameMedioPago();

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
                'remitos' => $remitos,
                'cheques' => $cheques
            ]);
        }
    }

    public function actionEleccion($id)
    {
        PermisosHelper::verificarPermiso('PagarVenta');

        $venta = new Ventas();
        $venta->IdVenta = $id;
        $venta->Dame();

        $pago = new Pagos();
        $pago->IdCheque = $id;
        $remitos=0;

        $pago->setScenario(Pagos::_ELECCION);

        if($pago->load(Yii::$app->request->post())){
            $pago->DameMedioPago();
            switch ($pago->MedioPago) {
                case 'Tarjeta':
                    PermisosHelper::verificarPermiso('PagarVentaTarjeta');
                    $pago->setScenario(Pagos::_ALTA_TARJETA);
                    break;
                case 'Efectivo':
                    PermisosHelper::verificarPermiso('PagarVentaEfectivo');
                    $pago->setScenario(Pagos::_ALTA_EFECTIVO);
                    break;
                case 'Mercaderia':
                    PermisosHelper::verificarPermiso('PagarVentaMercaderia');
                    $pago->setScenario(Pagos::_ALTA_MERCADERIA);
                    $remitos = (new GestorRemitos())->Buscar(0,'','A',0);
                    break;
                case 'Cheque':
                    PermisosHelper::verificarPermiso('PagarVentaCheque');
                    $pago->setScenario(Pagos::_ALTA_CHEQUE);
                    break;
            }
            return $this->renderAjax('alta', [
                'titulo' => 'Agregar pago',
                'model' => $pago,
                'remitos' => $remitos
            ]);
        } else {
            return $this->renderAjax('eleccion', [
                'titulo' => 'Elegir medio de pago',
                'model' => $pago
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('PagarVenta');

        $pago = new Pagos();
        $pago->IdPago = $id;
        $pago->Dame();

        $venta = new Ventas();
        $venta->IdVenta = $pago->IdVenta;
        $venta->Dame();

        $remitos=0;
        $cheques=0;

        switch ($pago->MedioPago) {
            case 'Tarjeta':
                PermisosHelper::verificarPermiso('ModificarPagoTarjeta');
                $pago->setScenario(Pagos::_MODIFICAR_TARJETA);
                break;
            case 'Efectivo':
                PermisosHelper::verificarPermiso('ModificarPagoEfectivo');
                $pago->setScenario(Pagos::_MODIFICAR_EFECTIVO);
                break;
            case 'Mercaderia':
                PermisosHelper::verificarPermiso('ModificarPagoMercaderia');
                $pago->setScenario(Pagos::_MODIFICAR_MERCADERIA);
                $remitos = (new GestorRemitos())->Buscar($venta->IdPuntoVenta,'','A',0,'N');
                $remito = new Remitos();
                $remito->IdRemito = $pago->IdRemito;
                $remito->Dame();
                array_push($remitos, $remito);
                break;
            case 'Cheque':
                PermisosHelper::verificarPermiso('ModificarPagoCheque');
                $pago->setScenario(Pagos::_MODIFICAR_CHEQUE);
                $cheques = (new GestorCheques())->Buscar();
                $cheque = new Cheques();
                $cheque->IdCheque = $pago->IdCheque;
                $cheque->Dame();
                array_push($cheques, $cheque);
                break;
        }

        if($pago->load(Yii::$app->request->post())){
            switch ($pago->MedioPago) {
                case 'Tarjeta':
                    $resultado = (new Ventas())->ModificarPagoTarjeta($pago);
                    break;
                case 'Efectivo':
                    $resultado = (new Ventas())->ModificarPagoEfectivo($pago);
                    break;
                case 'Mercaderia':
                    $resultado = (new Ventas())->ModificarPagoMercaderia($pago);
                    break;
                case 'Cheque':
                    $resultado = (new Ventas())->ModificarPagoCheque($pago);
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
                'titulo' => 'Modificar Pago',
                'model' => $pago,
                'remitos' => $remitos,
                'cheques' => $cheques
            ]);
        }
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarPagoVenta');

        Yii::$app->response->format = 'json';
        
        $pago = new Pagos();
        $pago->IdPago = $id;

        $resultado = (new Ventas())->BorrarPago($pago);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

}

?>