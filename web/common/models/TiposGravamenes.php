<?php
namespace common\models;

use Yii;
use yii\base\Model;

class TiposGravamenes extends Model
{
    public $IdTipoGravamen;
    public $TipoGravamen;
    public $Gravamen;
    public $FechaBaja;
    
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
            [['TipoGravamen','Gravamen'],
                'required', 'on' => self::_ALTA],
            [['IdTipoGravamen', 'TipoGravamen','Gravamen'],
                'required', 'on' => self::_MODIFICAR],
            [['IdTipoGravamen', 'TipoGravamen', 'Gravamen', 'FechaBaja'], 'safe']
        ];
    }

    /**
     * Permite instanciar un tipo de gravamen desde la base de datos.
     * xsp_dame_tipogravamen
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_tipogravamen( :IdTipoGravamen )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':IdTipoGravamen' => $this->IdTipoGravamen
        ]);
        
        $this->attributes = $query->queryOne();
    }


    /**
     * Permite cambiar el estado del Tipo de Gravamen a Baja siempre y cuando no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_tipogravamen
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_tipogravamen( :token, :IdTipoGravamen, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':IdTipoGravamen' => $this->IdTipoGravamen,
        ]);

        return $query->queryScalar();
    }
}