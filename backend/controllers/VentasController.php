<?php

namespace backend\controllers;

use common\models\Ventas;
use common\models\Clientes;
use common\models\PuntosVenta;
use common\models\GestorVentas;
use common\models\GestorClientes;
use common\models\GestorCanales;
use common\models\GestorTiposComprobantesAfip;
use common\models\GestorTiposTributos;
use common\models\forms\BuscarForm;
use common\models\forms\LineasForm;
use common\components\PermisosHelper;
use common\components\ComprobanteHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;
use yii\helpers\Url;

class VentasController extends BaseController
{
    public function actionAlta($id)
    {
        PermisosHelper::verificarPermiso('AltaVenta');

        $venta = new Ventas();
        $venta->setScenario(Ventas::_ALTA);

        if ($venta->load(Yii::$app->request->post()) && $venta->validate()) {
            $venta->IdPuntoVenta = $id;
            $gestor = new GestorVentas();
            $resultado = $gestor->Alta($venta);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $clientes = (new GestorClientes())->Listar();
            $comprobantes = GestorTiposComprobantesAfip::Buscar();
            $tributos = GestorTiposTributos::Buscar();
            $canales = GestorCanales::Buscar();

            return $this->renderAjax('alta', [
                'titulo' => 'Alta Venta',
                'model' => $venta,
                'clientes' => $clientes,
                'comprobantes' => $comprobantes,
                'tributos' => $tributos,
                'canales' => $canales
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarVenta');
        
        $venta = new Ventas();

        $venta->setScenario(Ventas::_MODIFICAR);

        if ($venta->load(Yii::$app->request->post())) {
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
            $clientes = (new GestorClientes())->Listar();
            $comprobantes = GestorTiposComprobantesAfip::Buscar();
            $tributos = GestorTiposTributos::Buscar();

            return $this->renderAjax('alta', [
                'titulo' => 'Editar Venta',
                'model' => $venta,
                'clientes' => $clientes,
                'comprobantes' => $comprobantes,
                'tributos' => $tributos
            ]);
        }
    }
    
    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarVenta');

        Yii::$app->response->format = 'json';
        
        $venta = new Ventas();
        $venta->IdVenta = $id;

        $resultado = GestorVentas::Borrar($venta);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarVenta');

        Yii::$app->response->format = 'json';
        
        $venta = new Ventas();
        $venta->IdVenta = $id;

        $resultado = $venta->Activar();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
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

        $cliente = new Clientes();
        $cliente->IdCliente = $venta->IdCliente;
        $cliente->Dame();

        $lineas = $venta->DameLineas();

        $pv = new PuntosVenta();
        $pv->IdPuntoVenta = $venta->IdPuntoVenta;
        $pv->Dame();
        $anterior = [
            'label' => "Punto de Venta: " . $pv->PuntoVenta,
            'link' => Url::to(['/puntos-venta/operaciones', 'id' => $venta->IdPuntoVenta])
        ];
        $titulo = "Venta #$id - Cliente: {$cliente->getNombre()}" . ($cliente->Observaciones ? " [{$cliente->Observaciones}]" : '');
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
        $venta->Dame();

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
        $venta->Dame();

        $resultado = $venta->QuitarLinea(Yii::$app->request->post('IdArticulo'));

        if (substr($resultado, 0, 2) != 'OK') {
            return ['error' => $resultado];
        }

        return ['error' => null];
    }

    public function actionComprobante($id)
    {
        $venta = new Ventas;
        $venta->IdVenta = $id;
        $venta->Dame();
        $comprobante = $venta->GenerarComprobante();

        $params = Yii::$app->session->get('Parametros');

        $res = ComprobanteHelper::ImprimirComprobante($params, $comprobante, $venta->Tipo === 'V');

        return Yii::$app->response->sendContentAsFile($res, 'Factura.pdf', [
            'inline' => true,
            'mimeType' => 'application/pdf'
        ]);
    }
}
