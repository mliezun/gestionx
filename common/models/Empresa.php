<?php
namespace common\models;

use Yii;
use yii\base\Model;

/**
 * @version 1.0
 * @created 21-Mar-2016 09:15:43
 */
class Empresa extends Model
{
    public $Parametro;
    public $Descripcion;
    public $Rango;
    public $Valor;
    public $EsEditable;
    public $EsInicial;

    const SCENARIO_EDITAR = 'editar';
    
    /**
     * Etiquetas de los campos.
     *
     * @return Array Etiquetas
     */
    public function attributeLabels()
    {
        return [
            'Parametro' => 'Parámetro'
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
            ['Valor', 'trim'],
            // Editar
            [['Parametro', 'Valor'], 'required', 'on' => self::SCENARIO_EDITAR],
            // Safe
            [['Valor', 'Parametro', 'Descripcion'], 'safe'],
        ];
    }

    /**
     * Permite buscar los parámetros editables del sistema dada una cadena de búsqueda.
     * Para listar todos, cadena vacía. xsp_buscar_parametros
     *
     * @param cadena    Cadena vacía para todos
     */
    public function BuscarParametros($cadena)
    {
        $sql = 'CALL xsp_buscar_parametros( :host, :cadena )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
            ':cadena' => $cadena
        ]);
        
        return $query->queryAll();
    }

    /**
     * Permite traer en formato resultset los parámetros de la empresa que necesitan
     *    cargarse al inicio de sesión (EsInicial = S). dame_datos_empresa
     */
    public function DameDatos()
    {
        $sql = "CALL xsp_dame_datos_empresa ( :host ) ";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
        ]);

        return $query->queryAll();
    }

    /**
     * Procedimiento que sirve para instanciar un parámetro del sistema desde la base
     * de datos. ssp_dame_parametro
     *
     * @param Parametro
     */
    public function DameParametro($Parametro)
    {
        $sql = "CALL xsp_dame_parametro ( :host, :parametro ) ";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
            ':parametro' => $Parametro,
        ]);

        $this->attributes = $query->queryOne();
    }

    /**
     * 
     */
    public function CambiarParametro($Parametro, $Valor, $Motivo, $Autoriza)
    {
        $sql = "CALL xsp_cambiar_parametro ( :token, :parametro, :valor, :motivo, :autoriza, :IP, :userAgent, :app ) ";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':parametro' => $Parametro,
            ':valor' => $Valor,
            ':motivo' => $Motivo,
            ':autoriza' => $Autoriza
        ]);

        return $query->queryScalar();
    }

    /**
     * Lista todos los usuarios activos que pertenecen al rol que tiene el permiso
     * Autorizacion. Los ordena por nombre de usuario.
     * xsp_listar_usuarios_autoriza_auditoria
     */
    public function ListarUsuariosAutorizaAuditoria()
    {
        $sql = "CALL xsp_listar_usuarios_autoriza_auditoria () ";

        $query = Yii::$app->db->createCommand($sql);

        return $query->queryAll();
    }
}
