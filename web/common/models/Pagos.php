<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Pagos extends Model
{
    public $IdPago;
    // public $IdVenta;
    public $Codigo;
    public $Tipo;
    public $IdMedioPago;
    public $IdUsuario;
    public $FechaAlta;
    public $FechaDebe;
    public $FechaPago;
    public $FechaAnula;
    public $Monto;
    public $Cantidad;
    public $Observaciones;
    public $IdRemito;
    public $IdCheque;
    public $NroTarjeta;
    public $MesVencimiento;
    public $AnioVencimiento;
    public $CCV;
    public $Datos;
    public $IdArticulo;

    //Derivados
    public $IdTipoComprobante;
    public $MedioPago;
    public $NroRemito;
    public $NroCheque;
    public $TipoComprobante;

    // Datos
    public $IdTipoTributo;
    public $Descuento;
    public $MontoVenta;

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
        8 => 'Descuento',
        1 => 'Efectivo',
        2 => 'Mercaderia',
        7 => 'Retencion',
        3 => 'Tarjeta',
        0 => 'Todos'
    ];

    public function attributeLabels()
    {
        return [
            'IdArticulo' => 'Artículo',
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
            ['Descuento', 'number', 'min' => 0, 'max' => 100],
            [['Codigo', 'Tipo','IdMedioPago','NroTarjeta','Monto'],
            'required', 'on' => self::_ALTA_TARJETA],
            [['Codigo', 'Tipo','IdMedioPago','Monto'],
            'required', 'on' => self::_ALTA_EFECTIVO],
            [['Codigo', 'Tipo','IdMedioPago','IdArticulo','Monto'],
            'required', 'on' => self::_ALTA_MERCADERIA],
            [['Codigo', 'Tipo','IdMedioPago','IdCheque'],
            'required', 'on' => self::_ALTA_CHEQUE],
            [['Codigo', 'Tipo','IdMedioPago','Monto','IdTipoTributo'],
            'required', 'on' => self::_ALTA_RETENCION],
            [['Codigo', 'Tipo','IdMedioPago'],
            'required', 'on' => self::_ELECCION],
            [['IdPago','Codigo', 'Tipo','IdMedioPago','NroTarjeta','Monto'],
            'required', 'on' => self::_MODIFICAR_TARJETA],
            [['IdPago','Codigo', 'Tipo','IdMedioPago','Monto'],
            'required', 'on' => self::_MODIFICAR_EFECTIVO],
            [['IdPago','Codigo', 'Tipo','IdMedioPago','IdArticulo','Monto','Cantidad'],
            'required', 'on' => self::_MODIFICAR_MERCADERIA],
            [['IdPago','Codigo', 'Tipo','IdMedioPago','IdCheque'],
            'required', 'on' => self::_MODIFICAR_CHEQUE],
            [['IdPago','Codigo', 'Tipo','IdMedioPago','IdTipoTributo','Monto'],
            'required', 'on' => self::_MODIFICAR_RETENCION],
            ['Monto', 'required', 'when' => function ($model) {
                return $model->IdMedioPago == 1 or $model->IdMedioPago == 6 or $model->IdMedioPago == 3 or $model->IdMedioPago == 2;
            }, 'whenClient' => "function (attribute, value) { 
                return parseInt($('ventas-idmediopago').val()) == 1 
                || parseInt($('ventas-idmediopago').val()) == 6
                || parseInt($('ventas-idmediopago').val()) == 3
                || parseInt($('ventas-idmediopago').val()) == 2;
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
