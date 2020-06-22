<?php
namespace common\models;

use Yii;
use yii\base\Model;

class RectificacionesPV extends Model
{
    public $IdRectificacionPV;
    public $IdArticulo;
    public $IdPuntoVentaOrigen;
    public $IdPuntoVentaDestino;
    public $IdEmpresa;
    public $IdUsuario;
    public $IdCanal;
    public $Cantidad;
    public $FechaAlta;
    public $Estado;
    public $Observaciones;

    // Derivados
    public $PuntoVentaOrigen;
    public $PuntoVentaDestino;
    public $Articulo;
    public $Canal;
    
    const _ALTA = 'alta';
    
    const ESTADOS = [
        'P' => 'Pendiente',
        'C' => 'Confirmada',
        'B' => 'Baja',
        'T' => 'Todos'
    ];
 
    public function rules()
    {
        return [
            [['IdArticulo','IdCanal','Cantidad'],
                'required', 'on' => self::_ALTA],
            [$this->attributes(), 'safe']
        ];
    }

    public function attributeLabels()
    {
        return [
            'IdArticulo' => 'Articulo',
            'IdCanal' => 'Canal',
            'IdPuntoVentaOrigen' => 'Punto de Venta de origen',
            'IdPuntoVentaDestino' => 'Punto de Venta de destino'
        ];
    }

    /**
     * Permite instanciar un punto venta desde la base de datos.
     * xsp_dame_puntoventa
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_puntoventa( :idPuntoVenta )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idPuntoVenta' => $this->IdPuntoVenta
        ]);
        
        $this->attributes = $query->queryOne();
    }

    /**
     * Permite confirmar una rectificacion, solamente si esta se encuentra pendiente de confirmación.
	 * Añade las existencias consolidadas en el destino.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_confirmar_rectificacionpv
     */
    public function Confirma()
    {
        $sql = "call xsp_confirmar_rectificacionpv( :token, :idrectificacion , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrectificacion' => $this->IdRectificacionPV,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del PuntoVenta a Baja siempre y cuando no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_puntoventa
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_puntoventa( :token, :idpuntoventa, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpuntoventa' => $this->IdPuntoVenta,
            ':observaciones' => $this->Observaciones,
        ]);

        return $query->queryScalar();
    }
}