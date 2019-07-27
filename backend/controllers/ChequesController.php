<?php

namespace backend\controllers;

use common\models\GestorCheques;
use common\models\GestorBancos;
use common\models\GestorClientes;
use common\models\Clientes;
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

    public function actionAlta($Tipo)
    {
        PermisosHelper::verificarPermiso('AltaCheque' . $Tipo);

        $cheque = new Cheques();
        $cheque->setScenario(Cheques::SCENARIO_ALTA);

        $gestor = new GestorCheques();

        if ($cheque->load(Yii::$app->request->post()) && $cheque->validate()) {
            Yii::$app->response->format = 'json';
            $resultado = $gestor->Alta($cheque);

            if (\substr($resultado, 0, 2) != 'OK') {
                return ['error' => $resultado];
            }

            return ['error' => null];
        }

        $gestorBancos = new GestorBancos;
        $bancos = $gestorBancos->Buscar();

        $gestorClientes = new GestorClientes;
        $clientes = array();
        foreach ($gestorClientes->Buscar() as $cliente) {
            $clientes[$cliente['IdCliente']] = Clientes::Nombre($cliente);
        }

        return $this->renderAjax('alta', [
            'model' => $cheque,
            'Tipo' => $Tipo,
            'bancos' => $bancos,
            'clientes' => $clientes
        ]);
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