<?php

namespace backend\controllers;

use common\models\Ventas;
use common\models\PuntosVenta;
use common\models\GestorVentas;
use common\models\GestorClientes;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

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
        $venta->IdVentas = $id;

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
        $urlAltaLinea = '/ventas/agregar-linea/' . $id;
        $urlQuitarLinea = '/ventas/quitar-linea/' . $id;

        return $this->render('@app/views/lineas/index', [
            'model' => $ingreso,
            'lineas' => $lineas,
            'anterior' => $anterior,
            'titulo' => $titulo,
            'urlAltaLinea' => $urlAltaLinea,
            'urlQuitarLinea' => $urlQuitarLinea,
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