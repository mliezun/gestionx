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

    private function armarCsv($delimiter)
    {
        $archivo = file_get_contents($this->Archivo->tempName, 'r');
        $archivo = "Articulo{$delimiter}Codigo{$delimiter}Descripcion{$delimiter}PrecioCosto{$delimiter}IVA\n" . $archivo;

        $file = tmpfile();
        $tmpath = stream_get_meta_data($file)['uri'];
        file_put_contents($tmpath, $archivo);

        $getcsv = function (string $input) use ($delimiter) {
            return \str_getcsv($input, $delimiter);
        };

        $csv = array_map($getcsv, file($tmpath));

        array_walk($csv, function (&$a) use ($csv) {
            $a = array_combine($csv[0], $a);
        });
        array_shift($csv);

        Yii::info($csv);

        return $csv;
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

        $delimiters = [',', ';'];

        $csv = [];

        foreach ($delimiters as $delimiter) {
            try {
                $csv = $this->armarCsv($delimiter);
            } catch (\Exception $ex) {
                Yii::error($ex);
            }
        }

        if (count($csv) == 0) {
            return 'El archivo está vacío o no tiene el formato correcto';
        }


        $sql = "call xsp_cargar_articulos_proveedor( :token, :idproveedor, :articulos, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idproveedor' => $this->IdProveedor,
            ':articulos' => json_encode($csv, JSON_INVALID_UTF8_IGNORE)
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
