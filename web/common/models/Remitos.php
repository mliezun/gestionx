<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Remitos extends Model
{
    public $IdRemito;
    public $NroRemito;
    public $CAI;
    public $NroFactura;
    public $FechaAlta;
    public $FechaFacturado;
    public $Estado;
    public $Observaciones;
    public $IdEmpresa;
    public $IdProveedor;
    public $IdCliente;
    public $IdCanal;

    // Derivados
    public $Canal;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'E' => 'Edicion',
        'B' => 'Baja',
        'T' => 'Todos'
    ];
 
    public function attributeLabels()
    {
        return [
            'IdProveedor' => 'Proveedor',
            'IdCanal' => 'Canal'
        ];
    }

    public function rules()
    {
        return [
            [['IdEmpresa', 'IdProveedor', 'IdCanal','NroRemito','CAI'],
                'required', 'on' => self::_ALTA],
            [['IdRemito', 'NroRemito','CAI'],
                'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    /**
     * Permite instanciar un remito desde la base de datos.
     * xsp_dame_remito
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_remito( :idRemito )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idRemito' => $this->IdRemito
        ]);
        
        $this->attributes = $query->queryOne();
    }

    /**
     * Permite cambiar el estado del Remito a Activo siempre y cuando el estado actual sea Edicion.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_remito
     */
    public function Activar()
    {
        $sql = "call xsp_activar_remito( :token, :idremito, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idremito' => $this->IdRemito,
            ':observaciones' => $this->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del Remito a Baja siempre y cuando no esté dado de baja.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_remito
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_remito( :token, :idremito, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idremito' => $this->IdRemito,
            ':observaciones' => $this->Observaciones,
        ]);

        return $query->queryScalar();
    }
}
