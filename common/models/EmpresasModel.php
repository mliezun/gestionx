<?php
namespace common\models;

use Yii;
use yii\base\Model;

class EmpresasModel extends Model
{
    public $IdEmpresa;
    public $Empresa;
    public $URL;
    public $Estado;

    const SCENARIO_ALTA = 'alta';

    const ESTADOS = [
        'A' => 'Activa',
        'B' => 'Baja'
    ];
    
    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            ['Empresa', 'trim'],
            ['URL', 'url'],
            // Alta
            [['Empresa', 'URL'], 'required', 'on' => self::SCENARIO_ALTA],
            // Safe
            [$this->attributes(), 'safe'],
        ];
    }

    
    /**
     * Permite dar de baja una empresa, controlando que exista y se encuentre activa.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_empresa
     * 
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_empresa( :token, :idempresa, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => $this->IdEmpresa
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite activar una empresa, controlando que exista y se encuentre activa.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_empresa
     * 
     */
    public function Activar()
    {
        $sql = "call xsp_activar_empresa( :token, :idempresa, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => $this->IdEmpresa
        ]);

        return $query->queryScalar();
    }
    
}
