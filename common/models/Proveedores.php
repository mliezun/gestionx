<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Proveedores extends Model
{
    public $IdProveedor;
    public $IdEmpresa;
    public $Proveedor;
    public $Descuento;
    public $Estado;

    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja'
    ];

    const SCENARIO_ALTA = 'alta';
    const SCENARIO_EDITAR = 'editar';

    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            ['Proveedor', 'trim'],
            ['Descuento', 'number'],
            // Alta
            [['IdEmpresa', 'Proveedor', 'Descuento'], 'required', 'on' => self::SCENARIO_ALTA],
            // Editar
            [['IdProveedor', 'Proveedor'], 'required', 'on' => self::SCENARIO_EDITAR],
            // Safe
            [['IdProveedor', 'IdEmpresa', 'Proveedor', 'Estado'], 'safe'],
        ];
    }

    /**
     * Permite instaciar un proveedor desde la base de datos.
     * xsp_dame_proveedor
     * 
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_proveedor( :id )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':id' => $this->IdProveedor
        ]);
        
        $res = $query->queryOne();
        
        $this->attributes = $res;
        
        return $res;
    }

    /**
     * Permite dar de baja un proveedor controlando que no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_proveedor
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_proveedor( :token, :idproveedor, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idproveedor' => $this->IdProveedor
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite activar un proveedor controlando que no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_proveedor
     */
    public function Activar()
    {
        $sql = "call xsp_activar_proveedor( :token, :idproveedor, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idproveedor' => $this->IdProveedor
        ]);

        return $query->queryScalar();
    }

}
