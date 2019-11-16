<?php

namespace backend\controllers;

use GuzzleHttp\Client;
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

    private function renderVHost($empresa)
    {
        return parent::renderPartial('@app/views/empresas/vhost.conf', [
            'empresa' => $empresa
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaEmpresa');

        $empresa = new EmpresasModel();
        $empresa->setScenario(EmpresasModel::SCENARIO_ALTA);

        $gestor = new GestorEmpresas();

        if ($empresa->load(Yii::$app->request->post()) && $empresa->validate()) {
            Yii::$app->response->format = 'json';
            $resultado = $gestor->Alta($empresa);

            if (\substr($resultado, 0, 2) != 'OK') {
                return ['error' => $resultado];
            }

            $vhost_conf = $this->renderVHost($empresa);

            $vhost_name = strtolower($empresa->Empresa);

            Yii::info($vhost_conf);
            Yii::info($vhost_name);

            $cmds = [
                "echo \"$vhost_conf\" > /etc/apache2/sites-available/{$vhost_name}.conf",
                "a2ensite $vhost_name",
                "service apache2 reload"
            ];

            $client = new Client();
            $response = $client->request('POST', 'http://127.0.0.1:3000/', [
                'json' => [
                    'cmds' => $cmds
                ]
            ]);

            if ($response->getBody() != 'OK') {
                return ['error' => 'Error al generar la configuración de apache.'];
            }

            return ['error' => null];
        }

        return $this->renderAjax('alta', [
            'model' => $empresa
        ]);
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
