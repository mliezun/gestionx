<?php
namespace common\models;

use Yii;
use yii\base\Model;
use common\models\forms\LineasForm;

class Ingresos extends Model
{
    public $IdIngreso;
    public $IdPuntoVenta;
    public $IdEmpresa;
    public $IdCliente;
    public $IdRemito;
    public $IdUsuario;
    public $FechaAlta;
    public $Estado;
    public $Observaciones;

    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja'
    ];

    const SCENARIO_ALTA = 'alta';

    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            // Safe
            [$this->attributes(), 'safe'],
        ];
    }

    /**
     * Permite instanciar un ingreso desde la base de datos.
     * xsp_dame_ingreso
     */
    public function Dame()
    {
        $sql = "call xsp_dame_ingreso( :idIngreso )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idIngreso' => $this->IdIngreso
        ]);

        $this->attributes = $query->queryOne();
    }

    /**
     * Permite quitar existencias, controlando que existan la cantidad de existencias
     * consolidadas suficientes para realizar esa acción.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_existencia
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_existencia( :token, :idIngreso, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idIngreso' => $this->IdIngreso
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite agregar una línea de ingreso a una existencia que se encuentre en estado En edición.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_alta_linea_existencia
     */
    public function AgregarLinea(LineasForm $linea)
    {
        $sql = "call xsp_alta_linea_existencia( :token, :idIngreso, :idart, :cant, :precio, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idIngreso' => $this->IdIngreso,
            ':idart' => $linea->IdArticulo,
            ':cant' => $linea->Cantidad,
            ':precio' => $linea->Precio
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite quitar una línea de ingreso a una existencia que se encuentre en estado En edición.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borrar_linea_existencia
     */
    public function QuitarLinea($IdArticulo)
    {
        $sql = "call xsp_borrar_linea_existencia( :token, :idIngreso, :idart, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idIngreso' => $this->IdIngreso,
            ':idart' => $IdArticulo
        ]);

        return $query->queryScalar();
    }

    public function DameLineas()
    {
        $sql = "call xsp_dame_lineas_ingreso( :idIngreso )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idIngreso' => $this->IdIngreso
        ]);

        return $query->queryAll();
    }
}
