<?php

namespace backend\controllers;

use common\models\GestorEmpresas;
use common\models\EmpresasModel;
use common\helpers\PermisosHelper;
use common\components\CmdHelper;
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

            $vhost_name = $empresa->vhost();

            Yii::info($vhost_conf);
            Yii::info($vhost_name);

            $tmp_vhost = \tmpfile();
            $meta_data = stream_get_meta_data($tmp_vhost);
            $tmp_vhost_path = $meta_data["uri"];

            \fwrite($tmp_vhost, $vhost_conf);

            $cmds = [
                "mv $tmp_vhost_path /etc/apache2/sites-available/{$vhost_name}.conf",
                "a2ensite $vhost_name",
                "service apache2 reload",
                "certbot --apache --non-interactive --redirect -d $empresa->URL"
            ];

            Yii::info($cmds);

            $resultado = CmdHelper::exec($cmds);

            fclose($tmp_vhost);

            if ($resultado != 'OK') {
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

        Yii::$app->response->format = 'json';

        $resultado = $empresa->Activar();

        if ($resultado == 'OK') {
            $empresa->Dame();
            $vhost_name = $empresa->vhost();

            Yii::info($vhost_name);

            $cmds = [
                "a2ensite $vhost_name",
                "a2ensite {$vhost_name}-le-ssl",
                "service apache2 reload"
            ];

            $resultado = CmdHelper::exec($cmds);

            if ($resultado != 'OK') {
                return ['error' => 'Error al generar la configuración de apache.'];
            }

            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaEmpresa');

        $empresa = new EmpresasModel();
        $empresa->IdEmpresa = $id;

        Yii::$app->response->format = 'json';

        $resultado = $empresa->DarBaja();

        if ($resultado == 'OK') {
            $empresa->Dame();
            $vhost_name = $empresa->vhost();

            Yii::info($vhost_name);

            $cmds = [
                "a2dissite $vhost_name",
                "a2dissite {$vhost_name}-le-ssl",
                "service apache2 reload"
            ];

            $resultado = CmdHelper::exec($cmds);

            if ($resultado != 'OK') {
                return ['error' => 'Error al generar la configuración de apache.'];
            }

            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
