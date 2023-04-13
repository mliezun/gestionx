<?php

namespace backend\controllers;

use common\models\GestorProveedores;
use common\models\GestorTiposTributos;
use common\models\Proveedores;
use common\models\forms\BuscarForm;
use common\helpers\PermisosHelper;
use common\helpers\FechaHelper;
use yii\helpers\ArrayHelper;
use yii\data\Pagination;
use yii\web\UploadedFile;
use Yii;
use common\helpers\InformesHelper;

class ProveedoresController extends BaseController
{
    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarProveedores');
        return parent::index(new GestorProveedores, ['Cadena', 'Check']);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaProveedor');

        $prov = new Proveedores();
        $prov->setScenario(Proveedores::SCENARIO_ALTA);

        $gestor = new GestorProveedores();

        return parent::alta($prov, [$gestor, 'Alta'], function () use ($prov) {
            $prov->IdEmpresa = Yii::$app->user->identity->IdEmpresa;
        });
    }

    public function actionAumento($id)
    {
        PermisosHelper::verificarPermiso('ModificarProveedor');

        $model = new Proveedores();
        $model->setScenario(Proveedores::SCENARIO_AUMENTO);

        if ($model->load(Yii::$app->request->post()) && $model->validate()) {
            Yii::$app->response->format = 'json';
            $resultado = $model->AplicarAumento();

            if (\substr($resultado, 0, 2) != 'OK') {
                return ['error' => $resultado];
            }

            return ['error' => null];
        }

        $model->IdProveedor = $id;
        $model->Dame();

        return $this->renderAjax('alta', [
            'model' => $model,
            'tipo' => 'aumento'
        ]);
    }

    public function actionCargar($id)
    {
        PermisosHelper::verificarPermiso('AltaArticulo');

        $model = new Proveedores();
        $model->IdProveedor = $id;

        if (Yii::$app->request->isPost) {
            Yii::$app->response->format = 'json';

            $model->Archivo = UploadedFile::getInstance($model, 'Archivo');

            $resultado = $model->CargarArticulos();

            if (\substr($resultado, 0, 2) != 'OK') {
                return ['error' => $resultado];
            }

            return ['error' => null];
        }

        $model->Dame();

        return $this->renderAjax('alta', [
            'model' => $model,
            'tipo' => 'carga'
        ]);
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarProveedor');
        
        $prov = new Proveedores();
        $prov->setScenario(Proveedores::SCENARIO_EDITAR);

        $gestor = new GestorProveedores();

        return parent::alta($prov, array($gestor, 'Modificar'), function () use ($prov, $id) {
            $prov->IdProveedor = $id;
            $prov->Dame();
        });
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarProveedor');

        $prov = new Proveedores();
        $prov->IdProveedor = $id;

        return parent::cambiarEstado($prov, 'Activar');
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaProveedor');

        $prov = new Proveedores();
        $prov->IdProveedor = $id;

        return parent::cambiarEstado($prov, 'DarBaja');
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarProveedor');

        $prov = new Proveedores();
        $prov->IdProveedor = $id;

        return parent::aplicarOperacionGestor($prov, array(new GestorProveedores, 'Borrar'));
    }

    public function actionHistorial($id)
    {
        self::agas();
        PermisosHelper::verificarPermiso('ListarHistorialDescuentosProveedor');

        $proveedor = new Proveedores();
        $proveedor->IdProveedor = $id;
        $proveedor->Dame();

        $historicos = $proveedor->ListarHistorialDescuentos();

        return $this->renderAjax('historial', [
            'models' => $historicos,
            'proveedor' => $proveedor
        ]);
    }

    public function actionCuentas($id)
    {
        // PermisosHelper::verificarPermiso('ListarHistorialDescuentosProveedor');

        $proveedor = new Proveedores();
        $proveedor->IdProveedor = $id;
        $proveedor->Dame();

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();
        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $fechaInicio = $busqueda->FechaInicio;
            $fechaFin = $busqueda->FechaFin;
            $historicos = $proveedor->ListarHistorialCuenta($fechaInicio, $fechaFin);
            $pagos = $proveedor->BuscarPagos($fechaInicio, $fechaFin);
        } else {
            $busqueda->FechaInicio = FechaHelper::formatearDateLocal(date("Y-m-d", strtotime(date("Y-m-d", strtotime(date("Y-m-d"))) . "-1 month")));
            $busqueda->FechaFin = FechaHelper::dateActualLocal();
            $historicos = $proveedor->ListarHistorialCuenta($busqueda->FechaInicio, $busqueda->FechaFin);
            $pagos = $proveedor->BuscarPagos($busqueda->FechaInicio, $busqueda->FechaFin);
        }

        $tributos = ArrayHelper::map((new GestorTiposTributos)->Buscar(), 'IdTipoTributo', 'TipoTributo');
        $paginado->totalCount = count($historicos);
        $historicos = array_slice($historicos, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('cuentas', [
            'busqueda' => $busqueda,
            'models' => $historicos,
            'pagos' => $pagos,
            'tributos' => $tributos,
            'proveedor' => $proveedor,
            'paginado' => $paginado,
        ]);
    }

    private static function agas()
    {
        $sql = "CALL xsp_inf_ejecutar_reporte ( :idEmpresa, :id, :cadena )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idEmpresa' => 2,
            ':id' => 8,
            ':cadena' => 'null,null'
        ]);

        $preresult = $query->queryAll();
        Yii::info(json_encode($preresult));
        $resultado = InformesHelper::expand($preresult);
        Yii::info(json_encode($resultado));

        // return $resultado;
    }
}
