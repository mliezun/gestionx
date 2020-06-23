<?php
namespace common\models;

use Yii;
use yii\base\Model;
use common\models\RectificacionesPV;

class PuntosVenta extends Model
{
    public $IdPuntoVenta;
    public $PuntoVenta;
    public $NroPuntoVenta;
    public $Datos;
    public $Estado;
    public $Observaciones;
    public $IdEmpresa;

    // DatosJSON
    public $Direccion;
    public $Telefono;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja',
        'T' => 'Todos'
    ];
 
    public function rules()
    {
        return [
            [['PuntoVenta','Direccion','Telefono','NroPuntoVenta'],
                'required', 'on' => self::_ALTA],
            [['IdPuntoVenta', 'PuntoVenta','Direccion','Telefono'],
                'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    public function attributeLabels()
    {
        return [
            'NroPuntoVenta' => 'Numero del Punto de Venta'
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
     * Permite cambiar el estado del PuntoVenta a Activo siempre y cuando no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_puntoventa
     */
    public function Activa()
    {
        $sql = "call xsp_activar_puntoventa( :token, :idpuntoventa, :observaciones , :IP, :userAgent, :app)";

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

    /**
     * Permite asignar el punto de venta al que pertenece un usuario, controlando que ambos pertenezcan a la misma empresa.
	 * Un usuario sólo puede pertenecer a un punto de venta. Por lo tanto se dan de baja las pertenencias anteriores y se 
	 * da de alta la nueva en estado activo.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_asignar_usuario_puntoventa
     */
    public function AsignarUsuario($IdUsuario)
    {
        $sql = "call xsp_asignar_usuario_puntoventa( :token, :idusuario, :idpuntoventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idusuario' => $IdUsuario,
            ':idpuntoventa' => $this->IdPuntoVenta,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite desasignar a un usuario del punto de venta.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_desasignar_usuario_puntoventa
     */
    public function DesasignarUsuario($IdUsuario)
    {
        $sql = "call xsp_desasignar_usuario_puntoventa( :token, :idusuario, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idusuario' => $IdUsuario
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar usuarios de un punto de venta, indicando una cadena de búsqueda y un punto de venta.
     * xsp_buscar_usuarios_puntosventa
     */
    public function BuscarUsuarios(string $Cadena = '')
    {
        $sql = 'CALL xsp_buscar_usuarios_puntosventa( :cadena, :idPuntoVenta )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':cadena' => $Cadena,
            ':idPuntoVenta' => $this->IdPuntoVenta
        ]);
        
        return $query->queryAll();
    }

    /**
     * Permite listar usuarios  asignables a un punto de venta.
     * xsp_dame_usuarios_asignar_puntosventa
     */
    public function DameUsuariosAsignar()
    {
        $sql = 'CALL xsp_dame_usuarios_asignar_puntosventa( :idPuntoVenta )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idPuntoVenta' => $this->IdPuntoVenta
        ]);
        
        return $query->queryAll();
    }

    /**
     * Procedimiento que sirve para listar las existencias de un punto venta desde la base de datos.
     * xsp_listar_existencias_puntosventa
     */
    public function ListarExistencias($cadena = '', $SinSotck = 'N', $idCanal = 0)
    {
        $sql = 'CALL xsp_listar_existencias_puntosventa( :cadena, :idPuntoVenta, :sinStock, :idCanal )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':cadena' => $cadena,
            ':idPuntoVenta' => $this->IdPuntoVenta,
            ':sinStock' => $SinSotck,
            ':idCanal' => $idCanal,
        ]);
        
        return $query->queryAll();
    }

    /**
     * Permite dar de alta una Rectificacion de Punto de Venta, incrementando o decrementando la cantidad
	 * de existencias de un articulo en un punto de venta con la posibilidad de que se aplique
	 * la accion contraria inmediatamente en otro punto de venta de la misma empresa
	 * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_rectificacionpv
     */
    public function AltaRectificacion(RectificacionesPV $Rectificacion)
    {
        $sql = "call xsp_alta_rectificacionpv( :token, :idempresa, :idorigen, :iddestino, :idarticulo, :idcanal, :cantidad".
        ", :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idorigen' => $this->IdPuntoVenta,
            ':iddestino' => intval($Rectificacion->IdPuntoVentaDestino),
            ':idarticulo' => $Rectificacion->IdArticulo,
            ':idcanal' => $Rectificacion->IdCanal,
            ':cantidad' => $Rectificacion->Cantidad,
            ':observaciones' => $Rectificacion->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar rectificaciones dentro de un punto de venta de una empresa, indicando una cadena de búsqueda
     * y si se incluyen bajas. Si pIdPuntoVenta = 0 lista todas las rectficaciones activos de una empresa.
     * xsp_buscar_rectificacionespv
     */
    public function ListarRectificaciones($cadena = '',$Incluye = 'N', $idCanal = 0)
    {
        $sql = 'CALL xsp_buscar_rectificacionespv(:idempresa, :idPuntoVenta, :idCanal, :cadena, :incluye )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idPuntoVenta' => $this->IdPuntoVenta,
            ':idCanal' => $idCanal,
            ':cadena' => $cadena,
            ':incluye' => $Incluye
        ]);
        
        return $query->queryAll();
    }

    /**
     * Permite borrar una Rectificacion de Punto de Venta, dentro del tiempo de anulacion.
	 * Siempre y cuando se encuentre pendiente de confirmación
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_rectificacionpv
     */
    public function BorrarRectificacion(RectificacionesPV $Rectificacion)
    {
        $sql = "call xsp_borra_rectificacionpv( :token, :idrectificacion,".
        " :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrectificacion' => $Rectificacion->IdRectificacionPV,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite devolver una rectificacion, solamente si esta se encuentra pendiente de confirmación.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_devolucion_rectificacionpv
     */
    public function DevolverRectificacion(RectificacionesPV $Rectificacion)
    {
        $sql = "call xsp_devolucion_rectificacionpv( :token, :idrectificacion,".
        " :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrectificacion' => $Rectificacion->IdRectificacionPV,
        ]);

        return $query->queryScalar();
    }
}