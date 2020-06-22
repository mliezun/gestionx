<?php

namespace common\models;

use Yii;
use yii\base\Model;

class Suscripciones extends Model
{
    public $IdSuscripcion;
    public $IdUsuario;
    public $IdPlan;
    public $FechaInicio;
    public $FechaFin;
    public $FechaBaja;
    public $AgenteBaja;
    public $Renovar;
    public $Estado;
    public $Bonificado;
    public $CodigoBonifUsado;
    public $Datos;
    
    // Derivados
    public $Plan;

    const ESTADOS = [
        'A' => 'Activa',
        'B' => 'Baja',
        'C' => 'Cancelada',
        'P' => 'Pendiente de alta',
        'F' => 'Pendiente de cancelación'
    ];

    public function rules()
    {
        return [
            // Safe
            [$this->attributes(), 'safe'],
        ];
    }

    /**
     * Coloca en estado 'F' (Pendiende de cancelación), a la suscripcion indicada.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_inicio_darbaja_suscripcion
     *
     */
    public function InicioDarBaja()
    {
        $sql = "CALL xsp_inicio_darbaja_suscripcion(:token, :idsuscripcion, :IP, :UserAgent, :Aplicacion)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':token' => Yii::$app->user->Identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':UserAgent' => Yii::$app->request->userAgent,
            ':Aplicacion' => Yii::$app->id,
            ':idsuscripcion' => $this->IdSuscripcion
        ]);

        return $query->queryScalar();
    }

    /**
     * Coloca en estado 'C' (Cancelada), a la suscripcion indicada.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_fin_darbaja_suscripcion
     *
     */
    public function FinDarBaja()
    {
        $sql = "CALL xsp_fin_darbaja_suscripcion(:idsuscripcion)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':idsuscripcion' => $this->IdSuscripcion
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite instanciar una suscripción desde la base de datos.
     */
    public function Dame()
    {
        $sql = "CALL xsp_dame_suscripcion(:IdSuscripcion)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':IdSuscripcion' => $this->IdSuscripcion,
        ]);

        $this->attributes = $query->queryOne();
    }

    /**
     * Permite instanciar una suscripción desde la base de datos a partir de los datos json.
     */
    public function DamePorDatos()
    {
        $sql = "CALL xsp_dame_suscripcion_por_datos(:datos)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':datos' => json_encode($this->Datos),
        ]);

        $datos = $this->Datos;

        $this->attributes = $query->queryOne();

        $this->Datos = $datos;
    }
}
