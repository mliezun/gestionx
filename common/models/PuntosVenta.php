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
}