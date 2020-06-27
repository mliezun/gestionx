<?php

namespace backend\controllers;

use common\models\GestorBancos;
use common\models\Bancos;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class BancosController extends BaseController
{
    public function actionListar($Cadena = '')
    {
        Yii::$app->response->format = 'json';

        $gestor = new GestorBancos();

        return $gestor->Buscar($Cadena);
    }

    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarBancos');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorBancos();

        if ($busqueda->load(Yii::$app->request->get()) && $busqueda->validate()) {
            $bancos = $gestor->Buscar($busqueda->Cadena, $busqueda->Combo ? $busqueda->Combo : 'A');
        } else {
            $bancos = $gestor->Buscar();
        }

        $paginado->totalCount = count($bancos);
        $bancos = array_slice($bancos, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $bancos,
            'busqueda' => $busqueda,
            'paginado' => $paginado
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaBanco');

        $banco = new Bancos();
        $banco->setScenario(Bancos::SCENARIO_ALTA);

        Yii::info(Yii::$app->request->post());

        $gestor = new GestorBancos();

        return parent::alta($banco, [$gestor, 'Alta'], function () use ($banco) {
        });
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarBanco');
        
        $banco = new Bancos();
        $banco->setScenario(Bancos::SCENARIO_EDITAR);

        $gestor = new GestorBancos();

        return parent::alta($banco, array($gestor, 'Modificar'), function () use ($banco, $id) {
            $banco->IdBanco = $id;
            $banco->Dame();
        });
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarBanco');

        $banco = new Bancos();
        $banco->IdBanco = $id;

        return parent::cambiarEstado($banco, 'Activar');
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaBanco');

        $banco = new Bancos();
        $banco->IdBanco = $id;

        return parent::cambiarEstado($banco, 'DarBaja');
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarBanco');

        $banco = new Bancos();
        $banco->IdBanco = $id;

        return parent::aplicarOperacionGestor($banco, array(new GestorBancos, 'Borrar'));
    }
}
