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
    public $Datos;

    //Derivados
    public $IdTipoComprobante;
    public $MedioPago;
    public $NroRemito;
    public $NroCheque;
    public $TipoComprobante;

    // Datos
    public $IdTipoTributo;

    const _ALTA_TARJETA = 'altat';
    const _ALTA_EFECTIVO = 'altae';
    const _ALTA_MERCADERIA = 'altam';
    const _ALTA_CHEQUE = 'altac';
    const _ALTA_DEPOSITO = 'altad';
    const _ALTA_RETENCION = 'altar';
    const _MODIFICAR_TARJETA = 'modificart';
    const _MODIFICAR_EFECTIVO = 'modificare';
    const _MODIFICAR_MERCADERIA = 'modificarm';
    const _MODIFICAR_CHEQUE = 'modificarc';
    const _MODIFICAR_RETENCION = 'modificarr';
    const _ELECCION = 'eleccion';

    const TIPOS = [
        'E' => 'Efectivo',
        'T' => 'Tarjeta',
        'D' => 'Deposito',
        'C' => 'Cheque',
        'M' => 'Mercaderia',
        'G' => 'Garantia',
        'R' => 'Retencion',
        'A' => 'Todos'
    ];

    const MEDIOS_PAGO = [
        5 => 'Cheque',
        6 => 'Deposito',
        1 => 'Efectivo',
        2 => 'Mercaderia',
        7 => 'Retencion',
        3 => 'Tarjeta',
        0 => 'Todos'
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
            'IdMedioPago' => 'Medio de Pago',
            'IdTipoTributo' => 'Tipo de Tributo',
        ];
    }
 
    public function rules()
    {
        return [
            ['Monto', 'double'],
            [['IdVenta','IdMedioPago','NroTarjeta','Monto'],
            'required', 'on' => self::_ALTA_TARJETA],
            [['IdVenta','IdMedioPago','Monto'],
            'required', 'on' => self::_ALTA_EFECTIVO],
            [['IdVenta','IdMedioPago','IdRemito','Monto'],
            'required', 'on' => self::_ALTA_MERCADERIA],
            [['IdVenta','IdMedioPago','IdCheque'],
            'required', 'on' => self::_ALTA_CHEQUE],
            [['IdVenta','IdMedioPago','Monto','IdTipoTributo'],
            'required', 'on' => self::_ALTA_RETENCION],
            [['IdVenta','IdMedioPago'],
            'required', 'on' => self::_ELECCION],
            [['IdPago','IdVenta','IdMedioPago','NroTarjeta','Monto'],
            'required', 'on' => self::_MODIFICAR_TARJETA],
            [['IdPago','IdVenta','IdMedioPago','Monto'],
            'required', 'on' => self::_MODIFICAR_EFECTIVO],
            [['IdPago','IdVenta','IdMedioPago','IdRemito','Monto'],
            'required', 'on' => self::_MODIFICAR_MERCADERIA],
            [['IdPago','IdVenta','IdMedioPago','IdCheque'],
            'required', 'on' => self::_MODIFICAR_CHEQUE],
            [['IdPago','IdVenta','IdMedioPago','IdTipoTributo','Monto'],
            'required', 'on' => self::_MODIFICAR_RETENCION],
            ['Monto', 'required', 'when' => function ($model) {
                return $model->IdMedioPago == 1 or $model->IdMedioPago == 6 or $model->IdMedioPago == 3;
            }, 'whenClient' => "function (attribute, value) { 
                return parseInt($('ventas-idmediopago').val()) == 1 
                || parseInt($('ventas-idmediopago').val()) == 6
                || parseInt($('ventas-idmediopago').val()) == 3;
            }"],
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
