<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Articulos extends Model
{
    public $IdArticulo;
    public $IdProveedor;
    public $IdEmpresa;
    public $Articulo;
    public $Codigo;
    public $Descripcion;
    public $PrecioCosto;
    public $PrecioVenta;
    public $IVA;
    public $FechaAlta;
    public $FechaActualizado;
    public $Estado;

    // Derivados
    public $Proveedor;

    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja'
    ];

    const SCENARIO_ALTA = 'alta';
    const SCENARIO_EDITAR = 'editar';

    public function attributeLabels()
    {
        return [
            'IdProveedor' => 'Proveedor'
        ];
    }

    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            ['Articulo', 'trim'],
            ['Codigo', 'trim'],
            ['Descripcion', 'trim'],
            // Alta
            [['IdEmpresa', 'IdProveedor', 'Articulo', 'Codigo', 'Descripcion', 'PrecioCosto', 'PrecioVenta',
            'IVA'], 'required', 'on' => self::SCENARIO_ALTA],
            // Editar
            [['IdArticulo', 'Articulo', 'Codigo', 'Descripcion', 'PrecioCosto', 'PrecioVenta',
            'IVA'], 'required', 'on' => self::SCENARIO_EDITAR],
            // Safe
            [['IdArticulo', 'IdEmpresa', 'IdProveedor', 'Articulo', 'Codigo', 'Descripcion', 'PrecioCosto', 'PrecioVenta',
            'IVA', 'FechaAlta', 'FechaActualizado', 'Estado'], 'safe'],
        ];
    }

    /**
     * Permite instaciar un artículo desde la base de datos.
     * xsp_dame_articulo
     * 
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_articulo( :id )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':id' => $this->IdArticulo
        ]);
        
        $res = $query->queryOne();
        
        $this->attributes = $res;
        
        return $res;
    }

    /**
     * Permite dar de baja un articulo controlando que no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_articulo
     * 
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_articulo( :token, :idarticulo, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idarticulo' => $this->IdArticulo
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite activar un articulo controlando que no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_articulo
     * 
     */
    public function Activar()
    {
        $sql = "call xsp_activar_articulo( :token, :idarticulo, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idarticulo' => $this->IdArticulo
        ]);

        return $query->queryScalar();
    }

}
