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
use common\components\EmailHelper;
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

        $canales = (new GestorCanales)->Buscar();
        if ($venta->load(Yii::$app->request->post()) && $venta->validate()) {
            $venta->IdPuntoVenta = $id;
            $venta->IdCanal = $venta->IdCanal ?? Yii::$app->session->get('Parametros')['CANALPORDEFECTO'];

            $venta->IdCanal = $canales[0]['IdCanal'];
            $gestor = new GestorVentas();
            $resultado = $gestor->Alta($venta);

            if (substr($resultado, 0, 2) !== 'OK') {
                Yii::$app->response->format = 'json';
                return ['error' => $resultado];
            }
            return $this->redirect(Url::to(['/ventas/lineas', 'id' => substr($resultado, 2)]));
        } else {
            $clientes = (new GestorClientes())->Listar();
            $comprobantes = (new GestorTiposComprobantesAfip)->Buscar('factura');
            $tributos = (new GestorTiposTributos)->Buscar();

            $venta->IdCanal = $canales[0]['IdCanal'];

            // Yii::info($venta->IdCanal, 'IdCanal');

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
            $comprobantes = (new GestorTiposComprobantesAfip)->Buscar();
            $tributos = (new GestorTiposTributos)->Buscar();
            $canales = (new GestorCanales)->Buscar();

            return $this->renderAjax('alta', [
                'titulo' => 'Editar Venta',
                'model' => $venta,
                'clientes' => $clientes,
                'comprobantes' => $comprobantes,
                'tributos' => $tributos,
                'canales' => $canales
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

    public function actionContador()
    {
        Yii::$app->response->format = 'json';

        $params = Yii::$app->session->get('Parametros');
        $cuit = $params['CUIT'];
        $cert = $params['AFIPCERT'];
        $key = $params['AFIPKEY'];
        $pvs = [4, 5];
        $tipos = [6, 1];
        $maximos = [
            6 => 25,
            1 => 8
        ];
        $out = [];
        foreach ($pvs as $pv) {
            foreach ($tipos as $tipo) {
                $out[] = ComprobanteHelper::ListarComprobantes($cuit, $cert, $key, true, $pv, $tipo, $maximos[$tipo]);
            }
        }
        return $out;
    }

    public function actionEnviarComprobante($id)
    {
        Yii::$app->response->format = 'json';

        $venta = new Ventas;
        $venta->IdVenta = $id;
        $venta->Dame();
        $comprobante = $venta->GenerarComprobante();

        $params = Yii::$app->session->get('Parametros');

        $res = ComprobanteHelper::ImprimirComprobante($params, $comprobante, $venta->Tipo === 'V');

        $datosCliente = json_decode($comprobante['Datos'], true);

        if (array_key_exists('Email', $datosCliente) && isset($datosCliente['Email']) && $datosCliente['Email'] != '') {
            $from = "{$params['EMPRESA']} <{$params['CORREONOTIFICACIONES']}>";
            $tempFile = tempnam(sys_get_temp_dir(), 'Factura') . '.pdf';
            $fileHandle = fopen($tempFile, 'w');
            fwrite($fileHandle, $res);
            EmailHelper::enviarEmail($from, $datosCliente['Email'], 'Factura de tu compra en ' . $params['EMPRESA'], 'factura', [], $tempFile);
            fclose($fileHandle);
            unlink($tempFile);
        } else {
            return ['error' => 'El cliente no tiene un email cargado'];
        }

        return ['error' => null];
    }
}
