<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Pagos extends Model
{
    public $IdPago;
    public $IdVenta;
    public $IdMedioPago;
    public $IdUsuario;
    public $FechaAlta;
    public $FechaDebe;
    public $FechaPago;
    public $FechaAnula;
    public $Monto;
    public $Observaciones;
    public $IdRemito;
    public $IdCheque;
    public $NroTarjeta;
    public $MesVencimiento;
    public $AnioVencimiento;
    public $CCV;

    //Derivados
    public $IdTipoComprobante;
    public $MedioPago;
    public $NroRemito;
    public $NroCheque;
    public $TipoComprobante;

    const _ALTA_TARJETA = 'altat';
    const _ALTA_EFECTIVO = 'altae';
    const _ALTA_MERCADERIA = 'altam';
    const _ALTA_CHEQUE = 'altac';
    const _MODIFICAR_TARJETA = 'modificart';
    const _MODIFICAR_EFECTIVO = 'modificare';
    const _MODIFICAR_MERCADERIA = 'modificarm';
    const _MODIFICAR_CHEQUE = 'modificarc';
    const _ELECCION = 'eleccion';

    const TIPOS = [
        'T' => 'Tarjeta',
        'E' => 'Efectivo',
        'C' => 'Cheque',
        'M' => 'Mercaderia',
        'A' => 'Todos'
    ];

    public function attributeLabels()
    {
        return [
            'IdRemito' => 'Remito',
            'NroRemito' => 'Nro de Remito',
            'NroCheque' => 'Nro de Cheque',
            'IdCheque' => 'Cheque',
            'TipoComprobante' => 'Tipo de Comprobante',
            'IdTipoComprobante' => 'Tipo de Comprobante',
            'MedioPago' => 'Medio de Pago',
            'IdMedioPago' => 'Medio de Pago'
        ];
    }
 
    public function rules()
    {
        return [
            ['Monto', 'double'],
            [['IdVenta','IdMedioPago','NroTarjeta','Monto'],
            'required', 'on' => self::_ALTA_TARJETA],
            [['IdVenta','IdMedioPago','IdRemito','Monto'],
            'required', 'on' => self::_ALTA_EFECTIVO],
            [['IdVenta','IdMedioPago','IdRemito','Monto'],
            'required', 'on' => self::_ALTA_MERCADERIA],
            [['IdVenta','IdMedioPago','IdCheque'],
            'required', 'on' => self::_ALTA_CHEQUE],
            [['IdVenta','IdMedioPago'],
            'required', 'on' => self::_ELECCION],
            [['IdPago','IdVenta','IdMedioPago','NroTarjeta','Monto'],
            'required', 'on' => self::_MODIFICAR_TARJETA],
            [['IdPago','IdVenta','IdMedioPago','IdRemito','Monto'],
            'required', 'on' => self::_MODIFICAR_EFECTIVO],
            [['IdPago','IdVenta','IdMedioPago','IdRemito','Monto'],
            'required', 'on' => self::_MODIFICAR_MERCADERIA],
            [['IdPago','IdVenta','IdMedioPago','IdCheque'],
            'required', 'on' => self::_MODIFICAR_CHEQUE],
            [$this->attributes(), 'safe']
        ];
    }

    /**
     * Permite instanciar un pago desde la base de datos.
     * xsp_dame_pago
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_pago( :idpago )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idpago' => $this->IdPago
        ]);
        
        $this->attributes = $query->queryOne();
    }

    public function DameMedioPago()
    {
        $sql = 'CALL xsp_dame_mediopago_pago( :MedioPago )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':MedioPago' => $this->MedioPago
        ]);
        
        $this->attributes = $query->queryOne();
    }
}
