<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Canales extends Model
{
    public $IdCanal;
    public $IdEmpresa;
    public $Canal;
    public $Estado;
    public $Observaciones;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja',
        'T' => 'Todos'
    ];
 
    public function rules()
    {
        return [
            ['Canal', 'trim'],
            //Alta
            [['Canal'], 'required', 'on' => self::_ALTA],
            //Modifica
            [['IdCanal', 'Canal'], 'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    /**
     * Procedimiento que sirve para instanciar un canal desde la base de datos.
     * xsp_dame_canal
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_canal( :id )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':id' => $this->IdCanal
        ]);
        
        $this->attributes = $query->queryOne();
    }

    /**
     * Permite cambiar el estado del Canal a Activo siempre y cuando no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_canal
     */
    public function Activa()
    {
        $sql = "call xsp_activar_canal( :token, :id, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $this->IdCanal,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del Canal a Baja siempre y cuando no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_canal
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_canal( :token, :id, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $this->IdCanal,
        ]);

        return $query->queryScalar();
    }
}
