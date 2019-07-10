<?php

namespace backend\controllers;

use common\models\Ingresos;
use common\models\PuntosVenta;
use common\models\Remitos;
use common\models\forms\LineasForm;
use common\components\PermisosHelper;
use yii\helpers\Url;
use Yii;

class IngresosController extends BaseController
{
    public function actionLineas($id)
    {
        $ingreso = new Ingresos();

        $ingreso->IdIngreso = $id;

        $ingreso->Dame();

        $lineas = $ingreso->DameLineas();

        if (isset($ingreso->IdRemito)) {
            $pv = new PuntosVenta();
            $pv->IdPuntoVenta = $ingreso->IdPuntoVenta;
            $pv->Dame();
            $anterior = [
                'label' => "Punto de Venta: " . $pv->PuntoVenta,
                'link' => Url::to(['/puntos-venta/operaciones', 'id' => $ingreso->IdPuntoVenta])
            ];
            $remito = new Remitos();
            $remito->IdRemito = $ingreso->IdRemito;
            $remito->Dame();
            $titulo = 'Remito ' . $remito->NroRemito;
            $urlAltaLinea = '/ingresos/agregar-linea/' . $id;
            $urlQuitarLinea = '/ingresos/quitar-linea/' . $id;
        }

        return $this->render('@app/views/lineas/index', [
            'model' => $ingreso,
            'lineas' => $lineas,
            'anterior' => $anterior,
            'titulo' => $titulo,
            'urlAltaLinea' => $urlAltaLinea,
            'urlQuitarLinea' => $urlQuitarLinea,
            'tipoPrecio' => 'PrecioCosto'
        ]);
    }

    public function actionAgregarLinea($id)
    {
        PermisosHelper::verificarPermiso('AltaLineaExistencia');
        Yii::$app->response->format = 'json';

        $ingreso = new Ingresos();

        $ingreso->IdIngreso = $id;

        $linea = new LineasForm();

        if ($linea->load(Yii::$app->request->post()) && $linea->validate(null, false)) {
            $resultado = $ingreso->AgregarLinea($linea);
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
        PermisosHelper::verificarPermiso('BorrarLineaExistencia');
        Yii::$app->response->format = 'json';

        $ingreso = new Ingresos();

        $ingreso->IdIngreso = $id;

        $resultado = $ingreso->QuitarLinea(Yii::$app->request->post('IdArticulo'));

        if (substr($resultado, 0, 2) != 'OK') {
            return ['error' => $resultado];
        }

        return ['error' => null];
    }
}

?>