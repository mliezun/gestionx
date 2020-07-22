<?php

namespace frontend\models\forms;

use yii\base\Model;

class ContactForm extends Model
{
    public $Email;
    public $Subject;
    public $Message;

    /**
     * Reglas para validar los formularios.
     *
     * @return Array Reglas de validación
     */
    public function rules()
    {
        return [
            [['Email', 'Subject', 'Message'], 'required'],
            ['Email', 'email']
        ];
    }
}
