<?php
namespace common\models;

use Yii;
use yii\base\Model;

class EmpresasModel extends Model
{
    public $IdEmpresa;
    public $Empresa;
    public $URL;
    public $Estado;

    const SCENARIO_ALTA = 'alta';

    const ESTADOS = [
        'A' => 'Activa',
        'B' => 'Baja'
    ];
    
    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            ['Empresa', 'trim'],
            // Alta
            [['Empresa', 'URL'], 'required', 'on' => self::SCENARIO_ALTA],
            // Safe
            [$this->attributes(), 'safe'],
        ];
    }

    /**
     * Permite obtener el vhost de una empresa.
     */
    public function vhost()
    {
        $unwanted_array = array(    'Š'=>'S', 'š'=>'s', 'Ž'=>'Z', 'ž'=>'z', 'À'=>'A', 'Á'=>'A', 'Â'=>'A', 'Ã'=>'A', 'Ä'=>'A', 'Å'=>'A', 'Æ'=>'A', 'Ç'=>'C', 'È'=>'E', 'É'=>'E',
                            'Ê'=>'E', 'Ë'=>'E', 'Ì'=>'I', 'Í'=>'I', 'Î'=>'I', 'Ï'=>'I', 'Ñ'=>'N', 'Ò'=>'O', 'Ó'=>'O', 'Ô'=>'O', 'Õ'=>'O', 'Ö'=>'O', 'Ø'=>'O', 'Ù'=>'U',
                            'Ú'=>'U', 'Û'=>'U', 'Ü'=>'U', 'Ý'=>'Y', 'Þ'=>'B', 'ß'=>'Ss', 'à'=>'a', 'á'=>'a', 'â'=>'a', 'ã'=>'a', 'ä'=>'a', 'å'=>'a', 'æ'=>'a', 'ç'=>'c',
                            'è'=>'e', 'é'=>'e', 'ê'=>'e', 'ë'=>'e', 'ì'=>'i', 'í'=>'i', 'î'=>'i', 'ï'=>'i', 'ð'=>'o', 'ñ'=>'n', 'ò'=>'o', 'ó'=>'o', 'ô'=>'o', 'õ'=>'o',
                            'ö'=>'o', 'ø'=>'o', 'ù'=>'u', 'ú'=>'u', 'û'=>'u', 'ý'=>'y', 'þ'=>'b', 'ÿ'=>'y' );

        $str = strtolower(str_replace(' ', '_', $this->Empresa));

        $str = strtr($str, $unwanted_array);

        return $str;
    }

    /**
     * Permite instanciar una empresa desde la base de datos.
     * xsp_dame_empresa
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_empresa( :id )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':id' => $this->IdEmpresa
        ]);
        
        $this->attributes = $query->queryOne();
    }

    
    /**
     * Permite dar de baja una empresa, controlando que exista y se encuentre activa.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_empresa
     *
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_empresa( :token, :idempresa, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => $this->IdEmpresa
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite activar una empresa, controlando que exista y se encuentre activa.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_empresa
     *
     */
    public function Activar()
    {
        $sql = "call xsp_activar_empresa( :token, :idempresa, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => $this->IdEmpresa
        ]);

        return $query->queryScalar();
    }
}
