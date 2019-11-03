<?php

namespace common\models;

use Yii;
use yii\base\Model;

class DestinosCheque extends Model
{
    public $IdDestinoCheque;
    public $Destino;
    public $Estado;

    const SCENARIO_ALTA = 'alta';
    const SCENARIO_EDITAR = 'editar';

    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja',
        'T' => 'Todos'
    ];

    public function rules()
    {
        return [
            ['Destino', 'trim'],
            [['Destino'], 'required', 'on' => self::SCENARIO_ALTA],
            [['Destino'], 'required', 'on' => self::SCENARIO_EDITAR],
            [$this->attributes(), 'safe']
        ];
    }


    /**
     * Permite instanciar un destino de cheque desde la base de datos.
     * xsp_dame_destino_cheque
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_destino_cheque( :iddestino )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':iddestino' => $this->IdDestinoCheque
        ]);
        
        $this->attributes = $query->queryOne();
    }


    /**
     * Permite dar de baja a un Destino de cheque siempre y cuando no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_destino_cheque
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_destino_cheque( :token, :iddestino, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':iddestino' => $this->IdDestinoCheque
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del Destino de cheque a Activo siempre y cuando no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_destino_cheque
     */
    public function Activar()
    {
        $sql = "call xsp_activar_destino_cheque( :token, :iddestino, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':iddestino' => $this->IdDestinoCheque
        ]);

        return $query->queryScalar();
    }
}