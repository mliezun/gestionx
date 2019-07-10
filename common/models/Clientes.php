<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Clientes extends Model
{
    public $IdCliente;
    public $IdEmpresa;
    public $Nombres;
    public $Apellidos;
    public $RazonSocial;
    public $Datos;
    public $FechaAlta;
    public $Tipo;
    public $Estado;
    public $Observaciones;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja',
        'T' => 'Todos'
    ];

    const TIPOS = [
        'F' => 'Fisica',
        'J' => 'Juridica',
        'T' => 'Todos'
    ];
 
    public function rules()
    {
        return [
            [['Datos','Tipo'],
                'required', 'on' => self::_ALTA],
            [['IdCliente','IdEmpresa','Datos','Tipo'],
                'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    /**
     * Permite instanciar un cliente desde la base de datos.
     * xsp_dame_cliente
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_cliente( :idcliente )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idcliente' => $this->IdCliente
        ]);
        
        $this->attributes = $query->queryOne();
    }


    /**
     * Permite dar de baja a un Cliente siempre y cuando no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_cliente
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_cliente( :token, :idcliente, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcliente' => $this->IdCliente
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del Cliente a Activo siempre y cuando no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_cliente
     */
    public function Activar()
    {
        $sql = "call xsp_activar_cliente( :token, :idcliente, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcliente' => $this->IdCliente
        ]);

        return $query->queryScalar();
    }
}