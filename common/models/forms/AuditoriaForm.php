<?php

namespace common\models\forms;

use yii\base\Model;

class AuditoriaForm extends Model
{
    public $Motivo;
    public $Autoriza;
    public $Observaciones;

    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            [['Motivo', 'Observaciones'], 'trim'],
            [['Motivo', 'Autoriza'], 'required']
        ];
    }
}
