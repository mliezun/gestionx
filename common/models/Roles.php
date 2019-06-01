<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Roles extends Model
{
    public $IdRol;
    public $Rol;
    public $Estado;
    public $Observaciones;
    public $IdEmpresa;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    const _BORRAR = 'borrar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja',
        'T' => 'Todos'
    ];
 
    public function rules()
    {
        return [
            [['Rol'],
                'required', 'on' => self::_ALTA],
            [['IdRol', 'Rol'],
                'required', 'on' => self::_MODIFICAR],
            [['IdRol', 'Rol', 'Estado', 'Observaciones','IdEmpresa'], 'safe']
        ];
    }

    /**
     * Permite instanciar un rol desde la base de datos.
     * xsp_dame_rol
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_rol( :idRol )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idRol' => $this->IdRol
        ]);
        
        $this->attributes = $query->queryOne();
    }
}
