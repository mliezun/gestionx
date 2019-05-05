<?php

namespace common\models;

use Yii;

class GestorRoles
{
    /**
     * Permite buscar los roles dada una cadena de búsqueda y la opción si incluye o no los dados de baja [S|N] respectivamente.
     * Para listar todos, cadena vacía.
     * xsp_buscar_roles
     * 
     */
    public function Buscar($Cadena = '', $IncluyeBajas = 'N')
    {
        $sql = "call xsp_buscar_roles( :host, :cadena, :incluyeBajas )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
            ':cadena' => $Cadena,
            ':incluyeBajas' => $IncluyeBajas,
        ]);

        return $query->queryAll();
    }
}