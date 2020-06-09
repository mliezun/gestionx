<?php

namespace common\widgets;

use common\models\Empresa;
use yii\base\Widget;
use yii\helpers\ArrayHelper;

class AuditoriaWidget extends Widget
{
    public $form;
    public $model;
    public $autorizadores;

    public function init()
    {
        parent::init();
        $empresa = new Empresa();
        $autorizadores = $empresa->ListarUsuariosAutorizaAuditoria();

        foreach ($autorizadores as &$autorizador) {
            $autorizador['Autorizador'] = $autorizador['Usuario'] . '(' . $autorizador['Nombres'] . ' ' . $autorizador['Apellidos'] . ')';
        }

        $this->autorizadores = ArrayHelper::map($autorizadores, 'Usuario', 'Autorizador');
    }

    public function run()
    {
        return $this->render('auditoria', [
                    'form' => $this->form,
                    'model' => $this->model,
                    'autorizadores' => $this->autorizadores,
        ]);
    }
}
