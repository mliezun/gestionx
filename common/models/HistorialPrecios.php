<?php
namespace common\models;

use Yii;
use yii\base\Model;

class HistorialPrecios extends Model
{
    public $IdHistorial;
    public $IdArticulo;
    public $Precio;
    public $FechaAlta;
    public $FechaFin;
    public $IdListaPrecio;
    
    // Derivados
    public $Articulo;
    public $Lista;
 
    public function rules()
    {
        return [
            [$this->attributes(), 'safe']
        ];
    }
}
