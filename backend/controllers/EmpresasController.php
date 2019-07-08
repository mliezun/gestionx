<?php

namespace backend\controllers;

use common\models\GestorEmpresas;
use common\models\EmpresasModel;
use common\components\PermisosHelper;
use Yii;

class EmpresasController extends BaseController
{
    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarEmpresas');
        return parent::index(new GestorEmpresas, ['Cadena', 'Check']);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaEmpresa');

        $empresa = new EmpresasModel();
        $empresa->setScenario(EmpresasModel::SCENARIO_ALTA);

        $gestor = new GestorEmpresas();

        return parent::alta($empresa, [$gestor, 'Alta'], function () {});
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarEmpresa');

        $empresa = new EmpresasModel();
        $empresa->IdEmpresa = $id;

        return parent::cambiarEstado($empresa, 'Activar');
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaEmpresa');

        $empresa = new EmpresasModel();
        $empresa->IdEmpresa = $id;

        return parent::cambiarEstado($empresa, 'DarBaja');
    }
}

?>