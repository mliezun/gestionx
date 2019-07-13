<?php
namespace common\models;

use Yii;
use yii\base\Model;
use common\models\forms\LineasForm;

class Ventas extends Model
{
    public $IdVenta;
    public $IdPuntoVenta;
    public $IdEmpresa;
    public $IdCliente;
    public $IdUsuario;
    public $Monto;
    public $FechaAlta;
    public $Tipo;
    public $Estado;
    public $Observaciones;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'E' => 'Edicion',
        'B' => 'Baja',
        'T' => 'Todos'
    ];

    const TIPOS_ALTA = [
        'P' => 'Presupuesto',
        'V' => 'Venta',
        'B' => 'Prestamo'
    ];

    const TIPOS = [
        'P' => 'Presupuesto',
        'V' => 'Venta',
        'B' => 'Prestamo',
        'T' => 'Todos'
    ];

    public function attributeLabels()
    {
        return [
            'IdCliente' => 'Cliente'
        ];
    }
 
    public function rules()
    {
        return [
            [['IdCliente','Tipo'],
                'required', 'on' => self::_ALTA],
            [['IdVenta','IdCliente','Tipo'],
                'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    /**
     * Permite instanciar una venta desde la base de datos.
     * xsp_dame_venta
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_venta( :idventa )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idventa' => $this->IdVenta
        ]);
        
        $this->attributes = $query->queryOne();
    }


    /**
     * Permite cambiar el estado de la Venta siempre y cuando no esté dado de baja ya.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_venta
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_venta( :token, :idventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado de la Venta a Activo siempre y cuando el estado actual sea Edicion.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_venta
     */
    public function Activar()
    {
        $sql = "call xsp_activar_venta( :token, :idventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite agregar una línea a una venta que se encuentre en estado En edición.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_alta_linea_venta
     */
    public function AgregarLinea(LineasForm $linea)
    {
        $sql = "call xsp_alta_linea_venta( :token, :idVenta, :idart, :cant, :precio, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idVenta' => $this->IdVenta,
            ':idart' => $linea->IdArticulo,
            ':cant' => $linea->Cantidad,
            ':precio' => $linea->Precio
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite quitar una línea a una venta que se encuentre en estado En edición.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borrar_linea_venta
     */
    public function QuitarLinea($IdArticulo)
    {
        $sql = "call xsp_borrar_linea_venta( :token, :idVenta, :idart, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idVenta' => $this->IdVenta,
            ':idart' => $IdArticulo
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite obtener las líneas de una venta.
     * xsp_dame_lineas_venta
     */
    public function DameLineas()
    {
        $sql = "call xsp_dame_lineas_venta( :idVenta )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idVenta' => $this->IdVenta
        ]);

        return $query->queryAll();
    }
}