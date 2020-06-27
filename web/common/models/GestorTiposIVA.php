<?php

namespace common\models;

use Yii;

class GestorTiposIVA
{
    /**
     * Permite buscar los tipos de iva dada una cadena de búsqueda y la opción si incluye o no
     * los dados de baja [S|N] respectivamente.
     * Para listar todos, cadena vacía.
     * xsp_buscar_tipos_iva
     */
    public function Buscar($Cadena = '', $IncluyeBajas = 'N')
    {
        $sql = "call xsp_buscar_tipos_iva(:cadena, :iBajas)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':cadena' => $Cadena,
            ':iBajas' => $IncluyeBajas,
        ]);

        return $query->queryAll();
    }
}
