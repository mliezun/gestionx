<?php

namespace backend\controllers;

use common\models\Remitos;
use common\models\GestorRemitos;
use common\models\GestorProveedores;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class RemitosController extends Controller
{
    public function actionIndex()
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorRemitos();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Combo2 ? $busqueda->Combo2 : 'E';
            $proveedor = $busqueda->Combo ? $busqueda->Combo : null;
            $remitos = $gestor->Buscar($busqueda->Cadena, $estado, $proveedor);
        } else {
            $remitos = $gestor->Buscar();
        }

        $paginado->totalCount = count($remitos);
        $remitos = array_slice($remitos, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        $gestorProv = new GestorProveedores();
        $proveedores = $gestorProv->Buscar();

        return $this->render('index', [
            'models' => $remitos,
            'busqueda' => $busqueda,
            'proveedores' => $proveedores
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaRemito');

        $remito = new Remitos();

        $remito->setScenario(Remitos::_ALTA);

        if($remito->load(Yii::$app->request->post())){
            $gestor = new GestorRemitos();
            $remito->IdEmpresa = Yii::$app->user->identity->IdEmpresa;
            $resultado = $gestor->Alta($remito);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        }else {
            return $this->renderAjax('alta', [
                'titulo' => 'Alta remito',
                'model' => $remito
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarRemito');
        
        $remito = new Remitos();

        $remito->setScenario(Remitos::_MODIFICAR);

        if ($remito->load(Yii::$app->request->post()) && $remito->validate()) {
            $gestor = new GestorRemitos();
            $resultado = $gestor->Modificar($remito);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $remito->IdRemito = $id;
            
            $remito->Dame();

            return $this->renderAjax('alta', [
                        'titulo' => 'Editar Remito',
                        'model' => $remito
            ]);
        }
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarRemito');

        Yii::$app->response->format = 'json';
        
        $remito = new Remitos();
        $remito->IdRemito = $id;

        $resultado = $remito->Activar();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaRemito');

        Yii::$app->response->format = 'json';
        
        $remito = new Remitos();
        $remito->IdRemito = $id;

        $resultado = $remito->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}

?>