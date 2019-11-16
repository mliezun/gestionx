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
    // Derivados
    public $Aumento;
    public $Archivo;

    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja'
    ];

    const SCENARIO_ALTA = 'alta';
    const SCENARIO_EDITAR = 'editar';
    const SCENARIO_AUMENTO = 'aumento';


    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            ['Proveedor', 'trim'],
            ['Descuento', 'number', 'min' => 0, 'max' => 100],
            // Alta
            [['IdEmpresa', 'Proveedor', 'Descuento'], 'required', 'on' => self::SCENARIO_ALTA],
            // Editar
            [['IdProveedor', 'Proveedor', 'Descuento'], 'required', 'on' => self::SCENARIO_EDITAR],
            // Aumento
            [['IdProveedor', 'Aumento'], 'required', 'on' => self::SCENARIO_AUMENTO],
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
     * Permite aplicar un aumento a todos los artículos de un proveedor. Devuelve OK o el mensaje de error en Mensaje.
     * xsp_aplicar_aumento_proveedor
     *
     */
    public function AplicarAumento()
    {
        $sql = "call xsp_aplicar_aumento_proveedor( :token, :idproveedor, :aumento, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idproveedor' => $this->IdProveedor,
            ':aumento' => $this->Aumento
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite hacer un alta/modifica masivo de artículos de un proveedor. Devuelve OK o el mensaje de error en Mensaje.
     * xsp_cargar_articulos_proveedor
     *
     */
    public function CargarArticulos()
    {
        if (!\strpos($this->Archivo->type, 'csv') && !\strpos($this->Archivo->type, 'vnd.ms-excel')) {
            return 'El archivo que intenta cargar no está en formato csv.';
        }
        $archivo = file_get_contents($this->Archivo->tempName, 'r');
        $archivo = "Articulo,Codigo,Descripcion,PrecioCosto,IVA\n" . $archivo;
        file_put_contents($this->Archivo->tempName, $archivo);

        $csv = array_map('str_getcsv', file($this->Archivo->tempName));
        array_walk($csv, function (&$a) use ($csv) {
            $a = array_combine($csv[0], $a);
        });
        array_shift($csv);

        $sql = "call xsp_cargar_articulos_proveedor( :token, :idproveedor, :articulos, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idproveedor' => $this->IdProveedor,
            ':articulos' => json_encode($csv)
        ]);

        return $query->queryScalar();
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

    /*
    * Permite listar el historial de descuentos de un proveedor.
    */
    public function ListarHistorialDescuentos()
    {
        $sql = 'CALL xsp_listar_historial_proveedor( :id)';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':id' => $this->IdProveedor,
        ]);
        
        return $query->queryAll();
    }
}
