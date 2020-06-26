<?php

namespace common\models;

use Yii;
use yii\base\Model;

class Bancos extends Model
{
    public $IdBanco;
    public $Banco;
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
            [['Banco'], 'required', 'on' => self::SCENARIO_ALTA],
            [['Banco'], 'required', 'on' => self::SCENARIO_EDITAR],
            [$this->attributes(), 'safe']
        ];
    }


    /**
     * Permite instanciar un banco desde la base de datos.
     * xsp_dame_banco
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_banco( :idbanco )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idbanco' => $this->IdBanco
        ]);
        
        $this->attributes = $query->queryOne();
    }


    /**
     * Permite dar de baja a un Banco siempre y cuando no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_banco
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_banco( :token, :idbanco, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idbanco' => $this->IdBanco
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del Banco a Activo siempre y cuando no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_banco
     */
    public function Activar()
    {
        $sql = "call xsp_activar_banco( :token, :idbanco, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idbanco' => $this->IdBanco
        ]);

        return $query->queryScalar();
    }
}
