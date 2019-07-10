<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Ventas extends Model
{
    public $IdVenta;
    public $IdPuntoVenta;
    public $IdEmpresa;
    public $IdCliente;
    public $IdUsuario;
    public $Monto;
    public $FechaAlta;
    public $Tipo;
    public $Estado;
    public $Observaciones;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'E' => 'Edicion',
        'B' => 'Baja',
        'T' => 'Todos'
    ];

    const TIPOS = [
        'P' => 'Presupuesto',
        'V' => 'Venta',
        'B' => 'Prestamo',
        'T' => 'Todos'
    ];
 
    public function rules()
    {
        return [
            [['IdPuntoVenta','IdEmpresa','IdCliente','IdUsuario','Monto','Tipo'],
                'required', 'on' => self::_ALTA],
            [['IdVenta','IdPuntoVenta','IdEmpresa','IdCliente','IdUsuario','Monto','Tipo'],
                'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    /**
     * Permite instanciar una venta desde la base de datos.
     * xsp_dame_venta
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_venta( :idventa )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idventa' => $this->IdVenta
        ]);
        
        $this->attributes = $query->queryOne();
    }


    /**
     * Permite cambiar el estado de la Venta siempre y cuando no esté dado de baja ya.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_venta
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_venta( :token, :idventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado de la Venta a Activo siempre y cuando el estado actual sea Edicion.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_venta
     */
    public function Activar()
    {
        $sql = "call xsp_activar_venta( :token, :idventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta
        ]);

        return $query->queryScalar();
    }
}