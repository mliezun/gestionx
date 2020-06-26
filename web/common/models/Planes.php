<?php

namespace common\models;

use Yii;
use yii\base\Model;

class Planes extends Model
{
    public $IdPlan;
    public $Plan;
    public $CantDias;
    public $Precio;
    public $Moneda;
    public $Descripcion;
    public $Estado;

    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja'
    ];

    const CANTDIAS = [
        365 => 'Anual',
        30 => 'Mensual',
        7 => 'Semanal',
        1 => 'Diaria'
    ];

    const SCENARIO_ALTA = 'alta';

    /**
     * Etiquetas de los campos.
     *
     * @return Array Etiquetas
     */
    public function attributeLabels()
    {
        return [
            'CantDias' => 'Frecuencia de pago',
            'Precio' => 'Precio [USD]',
        ];
    }


    public function rules()
    {
        return [
            [['CantDias'], 'integer'],
            [['CantDias'], 'in', 'range' => array_keys(self::CANTDIAS)],
            [['Precio'], 'double'],
            [['Plan', 'CantDias', 'Precio', 'Descripcion'], 'required', 'on' => self::SCENARIO_ALTA],
            // Safe
            [$this->attributes(), 'safe'],
        ];
    }

    /**
     * Busca un plan y devuelve los datos del plan. Si se indica un codigo de descuento,
     * devuelve el precio final de utilizar ese codigo de descuento.
     * La columna Descuento indica el valor total del descuento calculado.
     * xsp_dame_plan
     *
     */
    public function Dame($Codigo = '')
    {
        $sql = "CALL xsp_dame_plan (:IdPlan, :Codigo)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':Codigo' => $Codigo,
            ':IdPlan' => $this->IdPlan,
        ]);

        $this->attributes = $query->queryOne();
    }

    /**
     * Inhabilita un plan, colocando su estado en 'B'. Devuelve OK+Id o el mensaje de error en Mensaje.
     * xsp_baja_plan
     *
     */
    public function DarBaja()
    {
        $sql = "CALL xsp_baja_plan(:token, :IdPlan, :IP, :UserAgent, :Aplicacion)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':token' => Yii::$app->user->Identity->Token,
            ':IdPlan' => $this->IdPlan,
            ':IP' => Yii::$app->request->userIP,
            ':UserAgent' => Yii::$app->request->userAgent,
            ':Aplicacion' => Yii::$app->id,
        ]);

        return $query->queryScalar();
    }
}
