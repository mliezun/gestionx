<?php
namespace common\models;

use Yii;
use yii\base\Model;

class HistorialDescuentos extends Model
{
    public $IdHistorial;
    public $IdProveedor;
    public $Descuento;
    public $FechaAlta;
    public $FechaFin;
    
    // Derivados
    public $Proveedor;
 
    public function rules()
    {
        return [
            [$this->attributes(), 'safe']
        ];
    }
}
