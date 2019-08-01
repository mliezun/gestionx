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

    const _ALTA_TARJETA = 'altat';
    const _ALTA_EFECTIVO = 'altae';

    const TIPOS = [
        'T' => 'Tarjeta',
        'E' => 'Efectivo',
        'T' => 'Todos'
    ];

    public function attributeLabels()
    {
        return [
            'MedioPago' => 'Medio de Pago',
            'IdMedioPago' => 'Medio de Pago'
        ];
    }
 
    public function rules()
    {
        return [
            [['IdVenta','IdMedioPago','IdTipoComprobante','NroTarjeta','MesVencimiento','AnioVencimiento','CCV','Monto'],
            'required', 'on' => self::_ALTA_TARJETA],
            [['IdVenta','IdMedioPago','IdTipoComprobante','Monto'],
            'required', 'on' => self::_ALTA_EFECTIVO],
            [$this->attributes(), 'safe']
        ];
    }

    public function DameMedioPago($pago)
    {
        $sql = 'CALL xsp_dame_mediopago( :idMedioPago )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idMedioPago' => $pago->IdMedioPago
        ]);
        
        $pago->attributes = $query->queryOne();
    }
}