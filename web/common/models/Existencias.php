<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Existencias extends Model
{
    public $IdArticulo;
    public $IdPuntoVenta;
    public $Cantidad;

    // Derivados de Articulo
    public $Articulo;
    public $Codigo;
    public $Descripcion;
    public $PrecioCosto;
}
