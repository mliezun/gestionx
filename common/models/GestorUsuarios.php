<?php

namespace common\models;

use Yii;

class GestorUsuarios
{
    /**
     * Permite buscar los usuarios de una empresa dada una cadena de búsqueda, estado (T: todos los estados),
     * Rol (0: todos los roles). Si la cadena de búsqueda es un texto, busca por usuario, apellido
     * y nombre. Para listar todos, cadena vacía.
     * xsp_buscar_usuarios
     * 
     */
    public function Buscar($Cadena = '', $Estado = 'A', $IdRol = 0)
    {
        $sql = "call xsp_buscar_usuarios( :host, :cadena, :estado, :rol )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
            ':cadena' => $Cadena,
            ':estado' => $Estado,
            ':rol' => $IdRol,
        ]);

        return $query->queryAll();
    }
}