<?php

namespace backend\controllers;

use common\models\Ventas;
use common\models\Pagos;
use common\models\PuntosVenta;
use common\models\GestorVentas;
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

class VentasController extends BaseController
{
    public function actionAlta($id)
    {
        PermisosHelper::verificarPermiso('AltaVenta');

        $venta = new Ventas();

        $venta->setScenario(Ventas::_ALTA);

        if($venta->load(Yii::$app->request->post()) && $venta->validate()){
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
            return $this->renderAjax('alta', [
                'titulo' => 'Alta Venta',
                'model' => $venta
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

    public function actionAgregarPago($id)
    {
        PermisosHelper::verificarPermiso('PagarVenta');

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

    public function actionPdf()
    {
        $contenido = AfipHelper::generarPDF(json_decode('{
            "tipo_cbte": 201,
            "punto_vta": 4000,
            "fecha": "20190711",
            "concepto": 3,
            "tipo_doc": 80,
            "nro_doc": "30000000007",
            "cbte_nro": 12345678,
            "imp_total": "127.00",
            "imp_tot_conc": "3.00",
            "imp_neto": "100.00",
            "imp_iva": "21.00",
            "imp_trib": "1.00",
            "imp_op_ex": "2.00",
            "imp_subtotal": "105.00",
            "fecha_cbte": "20190711",
            "fecha_venc_pago": "20190711",
            "fecha_serv_desde": "20190711",
            "fecha_serv_hasta": "20190711",
            "moneda_id": "PES",
            "moneda_ctz": 1,
            "idioma_cbte": 1,
            "nombre_cliente": "Joao Da Silva",
            "domicilio_cliente": "Rua 76 km 34.5 Alagoas",
            "pais_dst_cmp": 200,
            "id_impositivo": "PJ54482221-l",
            "forma_pago": "30 dias",
            "obs_generales": "Observaciones Generales<br/>linea2<br/>linea3",
            "obs_comerciales": "Observaciones Comerciales<br/>texto libre",
            "motivo_obs": "Factura individual, DocTipo: 80, DocNro 30000000007 no se encuentra registrado en los padrones de AFIP.",
            "cae": "61123022925855",
            "fch_venc_cae": "20110320",
            "localidad_cliente": "Hurlingham",
            "provincia_cliente": "Buenos Aires",
            "subtotales_iva": [
                {
                    "iva_id": 5,
                    "base_imp": 100,
                    "importe": 21
                }
            ],
            "items": [
                {
                    "u_mtx": 123456,
                    "cod_mtx": 1234567890123,
                    "codigo": "P0001",
                    "ds": "Descripcion del producto P0001\nLorem ipsum sit amet ",
                    "qty": 1.00,
                    "umed": 7,
                    "precio": 110.00,
                    "imp_iva": 23.10,
                    "despacho": "Nº 123456",
                    "dato_a": "Dato A"
                }
            ],
            "custom-nro-cli": "Cod.123",
            "custom-pedido": "1234",
            "custom-remito": "12345",
            "custom-transporte": "Camiones Ej."
        }'));
        return Yii::$app->response->sendContentAsFile($contenido, 'Factura.pdf', [
            'mimeType' => 'application/pdf',
            'inline' => true
        ]);
    }
}

?>