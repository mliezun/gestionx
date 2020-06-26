<?php
namespace common\models;

use Yii;
use yii\base\Model;

class HistorialPorcentajes extends Model
{
    public $IdHistorial;
    public $IdListaPrecio;
    public $Porcentaje;
    public $FechaAlta;
    public $FechaFin;
    
    // Derivados
    public $Lista;
 
    public function rules()
    {
        return [
            [$this->attributes(), 'safe']
        ];
    }
}
