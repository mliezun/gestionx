<?php

namespace common\models;

use Yii;
use yii\base\Model;

class Cheques extends Model
{
    public $IdCheque;
    public $IdCliente;
    public $IdBanco;
    public $IdDestinoCheque;
    public $NroCheque;
    public $Importe;
    public $FechaAlta;
    public $FechaVencimiento;
    public $Estado;
    public $Obversaciones;

    // Derivados
    public $Banco;
    public $Destino;
    public $Descripcion;
    public $Tipo;

    const SCENARIO_ALTA = 'alta';
    const SCENARIO_ALTA_PROPIO = 'altapropio';
    const SCENARIO_EDITAR = 'editar';
    const SCENARIO_EDITAR_PROPIO = 'editarpropio';

    const ESTADOS = [
        'D' => 'Disponible',
        'U' => 'Utilizado',
        'T' => 'Todos'
    ];

    public function attributeLabels()
    {
        return [
            'IdBanco' => 'Banco',
            'IdDestinoCheque' => 'Destino',
            'IdCliente' => 'Cliente',
            'FechaVencimiento' => 'Fecha de Vencimiento',
            'Obversaciones' => 'Observaciones'
        ];
    }

    public function rules()
    {
        return [
            ['Importe', 'double'],
            [['IdBanco', 'NroCheque', 'Importe', 'FechaVencimiento'], 'required', 'on' => self::SCENARIO_ALTA],
            [['IdBanco', 'IdDestinoCheque', 'NroCheque', 'Importe', 'FechaVencimiento'], 'required', 'on' => self::SCENARIO_ALTA_PROPIO],
            [['IdBanco', 'NroCheque', 'Importe', 'FechaVencimiento'], 'required', 'on' => self::SCENARIO_EDITAR],
            [['IdBanco', 'IdDestinoCheque', 'NroCheque', 'Importe', 'FechaVencimiento'], 'required', 'on' => self::SCENARIO_EDITAR_PROPIO],
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