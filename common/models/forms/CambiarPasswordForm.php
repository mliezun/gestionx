<?php

namespace common\models\forms;

use yii\base\Model;

class CambiarPasswordForm extends Model
{
    public $Anterior;
    public $Password;
    public $Password_repeat;
    
    /**
     * Etiquetas de los campos.
     *
     * @return Array Etiquetas
     */
    public function attributeLabels()
    {
        return [
            'Anterior' => 'Contraseña actual',
            'Password' => 'Nueva contraseña',
            'Password_repeat' => 'Ingresar nuevamente la nueva contraseña'
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
            ['Password_repeat', 'compare', 'compareAttribute' => 'Password'],
            ['Password', 'required'],
            [['Password', 'Password_repeat'], 'trim' ],
            ['Password', 'string', 'length' => [6, 15]],
            ['Password', 'match', 'pattern' => '/^\d+$/','not'=> true,'message' => 'Debe tener al menos una letra.'],
            ['Password', 'match', 'pattern' => '/^\D+$/','not'=> true,'message' => 'Debe tener al menos un dígito.'],
            ['Anterior', 'required'],
            ['Password_repeat', 'safe'],
        ];
    }
}
