<?php

namespace common\models\forms;

use yii\base\Model;

class LineasForm extends Model
{
    public $IdArticulo;
    public $Cantidad;
    public $Precio;

    public function attributeLabels()
    {
        return [
            'IdArticulo' => 'Artículo'
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
            [['Cantidad', 'Precio'], 'double'],
            [['Cantidad'], 'compare', 'compareValue' => 0, 'operator' => '>', 'type' => 'number'],
            [['Precio'], 'compare', 'compareValue' => 0, 'operator' => '>=', 'type' => 'number'],
            [['IdArticulo', 'Cantidad'], 'required'],
            [['IdArticulo', 'Cantidad', 'Precio'], 'safe'],
        ];
    }
}
