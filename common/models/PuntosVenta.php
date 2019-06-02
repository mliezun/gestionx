<?php
namespace common\models;

use Yii;
use yii\base\Model;

class PuntosVenta extends Model
{
    public $IdPuntoVenta;
    public $PuntoVenta;
    public $Datos;
    public $Estado;
    public $Observaciones;
    public $IdEmpresa;
    
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
            [['PuntoVenta','Datos'],
                'required', 'on' => self::_ALTA],
            [['IdPuntoVenta', 'PuntoVenta','Datos'],
                'required', 'on' => self::_MODIFICAR],
            [['IdPuntoVenta', 'PuntoVenta', 'Datos', 'Estado', 'Observaciones','IdEmpresa'], 'safe']
        ];
    }

    /**
     * Permite instanciar un punto venta desde la base de datos.
     * xsp_dame_PuntoVenta
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
     * Permite cambiar el estado del Rol a Activo siempre y cuando no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_rol
     */
    public function Activa()
    {
        $sql = "call xsp_activar_rol( :token, :idrol, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrol' => $this->IdRol,
            ':observaciones' => $this->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del Rol a Baja siempre y cuando no esté dado de baja y no existan
     * usuarios activos asociados.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_rol
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_rol( :token, :idrol, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrol' => $this->IdRol,
            ':observaciones' => $this->Observaciones,
        ]);

        return $query->queryScalar();
    }
}