<?php

namespace backend\controllers;

use common\models\Ventas;
use common\models\Clientes;
use common\models\Pagos;
use common\models\Remitos;
use common\models\Cheques;
use common\models\Proveedores;
use common\models\PuntosVenta;
use common\models\GestorVentas;
use common\models\GestorRemitos;
use common\models\GestorClientes;
use common\models\GestorMediosPago;
use common\models\GestorTiposTributos;
use common\models\GestorCheques;
use common\models\forms\BuscarForm;
use common\models\forms\LineasForm;
use common\helpers\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;
use yii\helpers\Url;

class PagosController extends BaseController
{
    public function actionIndex($id)
    {
        // PermisosHelper::verificarPermiso('PagarVenta');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $venta = new Ventas();
        $venta->IdVenta = $id;
        $venta->Dame();

        $cliente = new Clientes();
        $cliente->IdCliente = $venta->IdCliente;
        $cliente->Dame();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $medio = $busqueda->Combo ? $busqueda->Combo : 0;
            $pagos = $venta->BuscarPagos($medio);
        } else {
            $pagos = $venta->DamePagos();
        }


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

        $tributos = ArrayHelper::map((new GestorTiposTributos)->Buscar(), 'IdTipoTributo', 'TipoTributo');

        return $this->render('index', [
            'model' => $venta,
            'pagos' => $pagos,
            'anterior' => $anterior,
            'titulo' => $titulo,
            'busqueda' => $busqueda,
            'tributos' => $tributos,
            'paginado' => $paginado
        ]);
    }

    public function actionAlta($id, $tipo = 'V')
    {
        switch ($tipo) {
            case 'V':
                $permiso = "Venta";
                $entidad = new Ventas();
                $entidad->IdVenta = $id;
                break;
            case 'P':
                $permiso = "Proveedor";
                $entidad = new Proveedores();
                $entidad->IdProveedor = $id;
                break;
            case 'C':
                $permiso = "Cliente";
                $entidad = new Clientes();
                $entidad->IdCliente = $id;
                break;
            default:
                return ['error' => 'Tipo no soportado.'];
                break;
        }

        $entidad->Dame();

        $pago = new Pagos();
        $pago->Codigo = $id;
        $pago->Tipo = $tipo;

        if ($pago->load(Yii::$app->request->post())) {
            switch ($pago->IdMedioPago) {
                case 3:
                    // Tarjeta
                    PermisosHelper::verificarPermiso('Pagar'.$permiso.'Tarjeta');
                    $pago->setScenario(Pagos::_ALTA_TARJETA);
                    if (!$pago->validate()) {
                        Yii::$app->response->format = 'json';
                        return ['error' => $pago->errors["NroTarjeta"] ?? $pago->errors["Monto"]];
                    }
                    $resultado = $entidad->PagarTarjeta($pago);
                    break;
                case 8:
                    // Descuento
                    if ($tipo == 'P' || $tipo == 'C') {
                        Yii::$app->response->format = 'json';
                        return ['error' => 'Medio de Pago no soportado.'];
                    }
                case 6:
                    // Deposito
                case 1:
                    // Efectivo
                    PermisosHelper::verificarPermiso('Pagar'.$permiso.'Efectivo');
                    $pago->setScenario(Pagos::_ALTA_EFECTIVO);
                    if (!$pago->validate()) {
                        Yii::$app->response->format = 'json';
                        return ['error' => $pago->errors["Monto"]];
                    }
                    $resultado = $entidad->PagarEfectivo($pago);
                    break;
                case 2:
                    if ($tipo == 'P' || $tipo == 'C') {
                        Yii::$app->response->format = 'json';
                        return ['error' => 'Medio de Pago no soportado.'];
                    }
                    // Mercaderia
                    PermisosHelper::verificarPermiso('Pagar'.$permiso.'Mercaderia');
                    $pago->setScenario(Pagos::_ALTA_MERCADERIA);
                    if (!$pago->validate()) {
                        Yii::$app->response->format = 'json';
                        return ['error' => $pago->errors["IdRemito"]];
                    }
                    $resultado = $entidad->PagarMercaderia($pago);
                    break;
                case 5:
                    // Cheque
                    PermisosHelper::verificarPermiso('Pagar'.$permiso.'Cheque');
                    $pago->setScenario(Pagos::_ALTA_CHEQUE);
                    if (!$pago->validate()) {
                        Yii::$app->response->format = 'json';
                        return ['error' => $pago->errors["IdCheque"]];
                    }
                    $resultado = $entidad->PagarCheque($pago);
                    break;
                case 7:
                    // Retencion
                    PermisosHelper::verificarPermiso('Pagar'.$permiso.'Retencion');
                    $pago->setScenario(Pagos::_ALTA_RETENCION);
                    if (!$pago->validate()) {
                        Yii::$app->response->format = 'json';
                        return ['error' => $pago->errors["IdTipoTributo"] ?? $pago->errors["Monto"]];
                    }
                    $resultado = $entidad->PagarRetencion($pago);
                    break;
            }

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            // $medios = (new GestorMediosPago)->Listar();
            $medios = (new GestorMediosPago)->Buscar($tipo);
            $tributos = (new GestorTiposTributos)->Buscar();
            $cheques = [];
            $remitos = [];
            switch ($tipo) {
                case 'V':
                    $pago->MontoVenta = $entidad->Monto;
                    $remitos = (new GestorRemitos())->Buscar($entidad->IdPuntoVenta, '', 'A', 0, 0, 'N');
                case 'C':
                    // Cheques del cliente
                    $cheques = (new GestorCheques())->Buscar('', '', '', 'D', 'T', $entidad->IdCliente);
                    break;
                default:
                    $cheques = (new GestorCheques())->Buscar('', '', '', 'D', 'T');
                    break;
            }

            $pago->setScenario(Pagos::_ELECCION);

            return $this->renderAjax('alta', [
                'titulo' => 'Agregar pago',
                'model' => $pago,
                'remitos' => $remitos,
                'medios' => $medios,
                'tributos' => $tributos,
                'cheques' => $cheques
            ]);
        }
    }

    // NO SE USA
    public function actionEleccion($id)
    {
        // PermisosHelper::verificarPermiso('PagarVenta');

        $venta = new Ventas();
        $venta->IdVenta = $id;
        $venta->Dame();

        $pago = new Pagos();
        $pago->IdCheque = $id;
        $remitos = 0;

        $pago->setScenario(Pagos::_ELECCION);

        if ($pago->load(Yii::$app->request->post())) {
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
                    $remitos = (new GestorRemitos())->Buscar(0, '', 'A', 0);
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

    public function actionEditar($id, $tipo = 'V')
    {
        $pago = new Pagos();
        $pago->IdPago = $id;
        $pago->Dame();

        switch ($tipo) {
            case 'V':
                $permiso = "Venta";

                $entidad = new Ventas();
                $entidad->IdVenta = $pago->Codigo;
                break;
            case 'P':
                $permiso = "Proveedor";

                $entidad = new Proveedores();
                $entidad->IdProveedor = $pago->Codigo;
                break;
            case 'C':
                $permiso = "Cliente";
                $entidad = new Clientes();
                $entidad->IdCliente = $pago->Codigo;
                break;
            default:
                return ['error' => 'Tipo no soportado.'];
                break;
        }

        $entidad->Dame();

        if ($tipo == 'V'){
            $pago->Descuento = ($pago->Monto / $entidad->Monto) * 100;
            $pago->MontoVenta = $entidad->Monto;
        }

        $tributos = [];
        $remitos = [];
        $cheques = [];

        switch ($pago->IdMedioPago) {
            case 3:
                // Tarjeta
                PermisosHelper::verificarPermiso('ModificarPago'.$permiso.'Tarjeta');
                $pago->setScenario(Pagos::_MODIFICAR_TARJETA);
                break;
            case 8:
                // Descuento
                if ($tipo == 'P' || $tipo == 'C') {
                    Yii::$app->response->format = 'json';
                    return ['error' => 'Medio de Pago no soportado.'];
                }
            case 6:
                // Deposito
            case 1:
                // Efectivo
                PermisosHelper::verificarPermiso('ModificarPago'.$permiso.'Efectivo');
                $pago->setScenario(Pagos::_MODIFICAR_EFECTIVO);
                break;
            case 2:
                if ($tipo == 'P' || $tipo == 'C') {
                    Yii::$app->response->format = 'json';
                    return ['error' => 'Medio de Pago no soportado.'];
                }
                // Mercaderia
                PermisosHelper::verificarPermiso('ModificarPago'.$permiso.'Mercaderia');
                $pago->setScenario(Pagos::_MODIFICAR_MERCADERIA);
                $remitos = (new GestorRemitos())->Buscar($entidad->IdPuntoVenta, '', 'A', 0, 0, 'N');
                $remito = new Remitos();
                $remito->IdRemito = $pago->IdRemito;
                $remito->Dame();
                array_push($remitos, $remito);
                break;
            case 5:
                // Cheque
                PermisosHelper::verificarPermiso('ModificarPago'.$permiso.'Cheque');
                $pago->setScenario(Pagos::_MODIFICAR_CHEQUE);
                if ($tipo == 'V' or $tipo == 'C') {
                    // Cheques del cliente
                    $cheques = (new GestorCheques())->Buscar('', '', '', 'D', 'T', $entidad->IdCliente);
                } else {
                    $cheques = (new GestorCheques())->Buscar('', '', '', 'D', 'T');
                }
                $cheque = new Cheques();
                $cheque->IdCheque = $pago->IdCheque;
                $cheque->Dame();
                array_push($cheques, $cheque);
                break;
            case 7:
                // Retencion
                PermisosHelper::verificarPermiso('ModificarPago'.$permiso.'Retencion');
                $pago->setScenario(Pagos::_MODIFICAR_RETENCION);
                $tributos = (new GestorTiposTributos)->Buscar();
                $pago->IdTipoTributo = json_decode($pago['Datos'])->IdTipoTributo;
                break;
        }

        if ($pago->load(Yii::$app->request->post())) {
            switch ($pago->IdMedioPago) {
                case 3:
                    $resultado = $entidad->ModificarPagoTarjeta($pago);
                    break;
                case 8:
                case 6:
                case 1:
                    $resultado = $entidad->ModificarPagoEfectivo($pago);
                    break;
                case 2:
                    $resultado = $entidad->ModificarPagoMercaderia($pago);
                    break;
                case 5:
                    $resultado = $entidad->ModificarPagoCheque($pago);
                    break;
                case 7:
                    $resultado = $entidad->ModificarPagoRetencion($pago);
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
                'tributos' => $tributos,
                'remitos' => $remitos,
                'cheques' => $cheques
            ]);
        }
    }

    public function actionBorrar($id, $tipo = 'V')
    {
        switch ($tipo) {
            case 'V':
                $permiso = "Venta";
                $entidad = new Ventas();
                break;
            case 'P':
                $permiso = "Proveedor";
                $entidad = new Proveedores();
                break;
            case 'C':
                $permiso = "Cliente";
                $entidad = new Clientes();
                break;
            default:
                return ['error' => 'Tipo no soportado.'];
                break;
        }

        PermisosHelper::verificarPermiso('BorrarPago'. $permiso );

        Yii::$app->response->format = 'json';

        $pago = new Pagos();
        $pago->IdPago = $id;

        $resultado = $entidad->BorrarPago($pago);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
