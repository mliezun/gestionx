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
    public $FechaAlta;
    public $Estado;

    // Derivados
    public $Proveedor;
    public $Gravamenes;
    public $PreciosVenta;
    // Precio por defecto
    public $PrecioVenta;

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
            [['IdEmpresa', 'IdProveedor', 'Articulo', 'Codigo', 'Descripcion', 'PrecioCosto', 'PrecioVenta', 'PreciosVenta',
            'Gravamenes'], 'required', 'on' => self::SCENARIO_ALTA],
            // Editar
            [['IdArticulo', 'Articulo', 'Codigo', 'Descripcion', 'PrecioCosto', 'PrecioVenta', 'PreciosVenta',
            'Gravamenes'], 'required', 'on' => self::SCENARIO_EDITAR],
            // Safe
            [$this->attributes(), 'safe'],
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
        
        $this->attributes = $query->queryOne();

        foreach (json_decode($this->PreciosVenta) as $nombre => $valor){
            if($nombre == 'Por Defecto'){
                $this->PrecioVenta = $valor;
            }
        }
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

    public function ListarGravamenes()
    {
        $sql = 'CALL xsp_listar_gravamenes( :id )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':id' => $this->IdArticulo
        ]);
        
        return $query->queryAll();
    }

    public function DameListasPrecios()
    {
        $sql = 'CALL xsp_listar_listas_precios_articulos( :id )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':id' => $this->IdArticulo
        ]);
        
        return $query->queryAll();
    }

    /**
     * Permite dar de alta un precio de un articulo. Controlando que precio no
     * existan ya dentro de la misma lista.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_alta_precio_articulo
     */
    public function AgregarPrecio(PreciosArticulos $Precio)
    {
        $sql = "call xsp_alta_precio_articulo( :token, :idarticulo, :idlistaprecio, :pventa, "
            . ":IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idarticulo' => $this->IdArticulo,
            ':idlistaprecio' => $Precio->IdListaPrecio,
            ':pventa' => $Precio->PrecioVenta,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar un precio de un articulo. Controlando que el precio
     * existan ya dentro de la misma lista.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_precio_articulo
     */
    public function ModificarPrecio(PreciosArticulos $Precio)
    {
        $sql = "call xsp_modifica_precio_articulo( :token, :idarticulo, :idlistaprecio, :pventa, "
            . ":IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idarticulo' => $this->IdArticulo,
            ':idlistaprecio' => $Precio->IdListaPrecio,
            ':pventa' => $Precio->PrecioVenta,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite borrar un precio de un articulo. Controlando que el precio
     * existan ya dentro de la misma lista.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_precio_articulo
     */
    public function BorrarPrecio(PreciosArticulos $Precio)
    {
        $sql = "call xsp_borra_precio_articulo( :token, :idarticulo, :idlistaprecio, "
            . ":IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idarticulo' => $this->IdArticulo,
            ':idlistaprecio' => $Precio->IdListaPrecio,
        ]);

        return $query->queryScalar();
    }
}
