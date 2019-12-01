<?php

namespace backend\controllers;

use common\components\PermisosHelper;
use common\models\Empresa;
use common\models\forms\BuscarForm;
use Yii;
use yii\helpers\ArrayHelper;

class EmpresaController extends BaseController
{
    public function actionIndex()
    {
        return $this->actionListar();
    }

    public function actionListar($Cadena = '')
    {
        PermisosHelper::verificarPermiso('BuscarParametro');

        $gestor = new Empresa();

        $busqueda = new BuscarForm();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $Cadena = $busqueda->Cadena;
        }

        $parametros = $gestor->BuscarParametros($Cadena);

        return $this->render('index', [
                    'models' => $parametros,
                    'busqueda' => $busqueda,
        ]);
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarParametro');

        $parametro = new Empresa();
        $parametro->setScenario(Empresa::SCENARIO_EDITAR);

        if ($parametro->load(Yii::$app->request->post()) && $parametro->validate()) {
            $gestor = new Empresa();
            $resultado = $gestor->CambiarParametro($parametro->Parametro, $parametro->Valor);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                //Vuelvo a obtener los parámetros
                $empresa = new Empresa();
                Yii::$app->session->set('Parametros', ArrayHelper::map($empresa->DameDatos(), 'Parametro', 'Valor'));
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $parametro->DameParametro($id);
            return $this->renderAjax('alta', [
                        'titulo' => 'Editar parámetro',
                        'model' => $parametro
            ]);
        }
    }
}
