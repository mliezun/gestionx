<?php

namespace common\models;

use Yii;
use yii\base\Model;

class Cheques extends Model
{
    public $IdCheque;
    public $IdCliente;
    public $IdBanco;
    public $NroCheque;
    public $Importe;
    public $FechaAlta;
    public $FechaVencimiento;
    public $Estado;
    public $Observaciones;

    // Derivados
    public $Banco;
    public $Descripcion;
    public $Tipo;

    const SCENARIO_ALTA = 'alta';
    const SCENARIO_EDITAR = 'editar';

    const ESTADOS = [
        'D' => 'Disponible',
        'U' => 'Utilizado',
        'T' => 'Todos'
    ];

    public function attributeLabels()
    {
        return [
            'IdBanco' => 'Banco',
            'IdCliente' => 'Cliente'
        ];
    }

    public function rules()
    {
        return [
            [['IdBanco', 'NroCheque', 'Importe', 'FechaVencimiento'], 'required', 'on' => self::SCENARIO_ALTA],
            [['IdBanco', 'NroCheque', 'Importe', 'FechaVencimiento'], 'required', 'on' => self::SCENARIO_EDITAR],
            [$this->attributes(), 'safe']
        ];
    }


    /**
     * Permite instanciar un cheque desde la base de datos.
     * xsp_dame_cheque
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_cheque( :idcheque )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idcheque' => $this->IdCheque
        ]);
        
        $this->attributes = $query->queryOne();
    }

}