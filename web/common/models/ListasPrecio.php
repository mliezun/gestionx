<?php
namespace common\models;

use Yii;
use yii\base\Model;

class ListasPrecio extends Model
{
    public $IdListaPrecio;
    public $IdEmpresa;
    public $Lista;
    public $Porcentaje;
    public $Estado;
    public $Observaciones;
    
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
            ['Lista', 'trim'],
            ['Porcentaje', 'number'],
            //Alta
            [['Lista','Porcentaje'],
                'required', 'on' => self::_ALTA],
            //Modifica
            [['IdListaPrecio', 'Lista', 'Porcentaje'],
                'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    /**
     * Procedimiento que sirve para instanciar una lista de precios desde la base de datos.
     * xsp_dame_lista_precio
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_lista_precio( :idlista )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idlista' => $this->IdListaPrecio
        ]);
        
        $this->attributes = $query->queryOne();
    }

    /**
     * Permite cambiar el estado del Rol a Activo siempre y cuando no esté activo ya. Devuelve OK o el mensaje de error en Mensaje.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_lista_precio
     */
    public function Activa()
    {
        $sql = "call xsp_activar_lista_precio( :token, :idlista , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idlista' => $this->IdListaPrecio,
        ]);

        return $query->queryScalar();
    }

    /*
    * Permite listar el historial de porcentajes de una lista de precio.
    */
    public function ListarHistorialPorcentajes()
    {
        $sql = 'CALL xsp_listar_historial_lista_precio( :id)';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':id' => $this->IdListaPrecio,
        ]);
        
        return $query->queryAll();
    }
}
