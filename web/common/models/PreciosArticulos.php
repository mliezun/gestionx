<?php
namespace common\models;

use Yii;
use yii\base\Model;

class PreciosArticulos extends Model
{
    public $IdListaPrecio;
    public $IdArticulo;
    public $PrecioVenta;
    public $FechaAlta;

    //Derivados
    public $Lista;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
 
    public function rules()
    {
        return [
            [['PrecioVenta', 'IdListaPrecio'],
                'required', 'on' => self::_ALTA],
            [['PrecioVenta', 'IdListaPrecio', 'IdArticulo'],
                'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    public function attributeLabels()
    {
        return [
            'IdListaPrecio' => 'Lista',
            'PrecioVenta' => 'Precio'
        ];
    }

    /**
     * Procedimiento que sirve para instanciar un precio articulo desde la base de datos.
     * xsp_dame_precio_articulo
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_precio_articulo( :idarticulo, :idlista )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idarticulo' => $this->IdArticulo,
            ':idlista' => $this->IdListaPrecio
        ]);
        
        $this->attributes = $query->queryOne();
    }
}
