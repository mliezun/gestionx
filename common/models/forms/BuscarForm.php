<?php

namespace common\models\forms;

use yii\base\Model;

class BuscarForm extends Model
{
    public $Cadena;
    public $Check;
    public $FechaInicio;
    public $FechaFin;
    public $Id;
    public $Numero;
    public $Combo;
    public $Numero2;
    public $Combo2;
    public $Combo3;
    public $Combo4;
    public $Periodo;

    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            [['Cadena'], 'trim'],
            ['Check', 'in', 'range' => ['S', 'N']],
            [['Numero', 'Id', 'Numero2'], 'integer', 'min' => 0],
            [['Numero', 'Id', 'Numero2', 'Combo', 'Combo2', 'Combo3', 'Combo4'], 'default', 'value' => 0],
            [['Check', 'FechaInicio', 'FechaFin', 'Id', 'Numero', 'Combo',
                'Combo2', 'Combo3', 'Cadena', 'Numero2', 'Combo4', 'Periodo'], 'safe'],
        ];
    }
}
