<?php

namespace backend\controllers;

use common\models\GestorCheques;
use common\models\Cheques;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class ChequesController extends BaseController
{

    public function actionListar($Cadena = '')
    {
        Yii::$app->response->format = 'json';

        $gestor = new GestorCheques();

        return $gestor->Buscar($Cadena);
    }

    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarCheques');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorCheques();

        if ($busqueda->load(Yii::$app->request->get()) && $busqueda->validate()) {
            $estado = $busqueda->Combo ? $busqueda->Combo : 'D';
            $cheques = $gestor->Buscar($busqueda->Cadena, $busqueda->FechaInicio, $busqueda->FechaFin, $estado);
        } else {
            $cheques = $gestor->Buscar();
        }

        $paginado->totalCount = count($cheques);
        $cheques = array_slice($cheques, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $cheques,
            'busqueda' => $busqueda,
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaCheque');

        $cheque = new Cheques();
        $cheque->setScenario(Cheques::SCENARIO_ALTA);

        Yii::info(Yii::$app->request->post());

        $gestor = new GestorCheques();

        return parent::alta($cheque, [$gestor, 'Alta'], function () use ($cheque) {});
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarCheque');
        
        $cheque = new Cheques();
        $cheque->setScenario(Cheques::SCENARIO_EDITAR);

        $gestor = new GestorCheques();

        return parent::alta($cheque, array($gestor, 'Modificar'), function () use ($cheque, $id) {
            $cheque->IdCheque = $id;
            $cheque->Dame();
        });
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarCheque');

        $cheque = new Cheques();
        $cheque->IdCheque = $id;

        return parent::cambiarEstado($cheque, 'Activar');
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaCheque');

        $cheque = new Cheques();
        $cheque->IdCheque = $id;

        return parent::cambiarEstado($cheque, 'DarBaja');
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarCheque');

        $cheque = new Cheques();
        $cheque->IdCheque = $id;

        return parent::aplicarOperacionGestor($cheque, array(new GestorCheques, 'Borrar'));
    }
}

?>