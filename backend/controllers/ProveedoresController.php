<?php

namespace backend\controllers;

use common\models\GestorProveedores;
use common\models\Proveedores;
use common\components\PermisosHelper;
use Yii;

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
}

?>