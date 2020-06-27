<?php

namespace common\models;

use Yii;

class GestorTiposComprobantesAfip
{
    /**
     * Permite buscar los tipos de comprobantes dada una cadena de búsqueda y la opción si incluye o no
     * los dados de baja [S|N] respectivamente.
     * Para listar todos, cadena vacía.
     * xsp_buscar_tipos_comprobantes_afip
     */
    public function Buscar($Cadena = '', $IncluyeBajas = 'N')
    {
        $sql = "call xsp_buscar_tipos_comprobantes_afip(:cadena, :iBajas)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':cadena' => $Cadena,
            ':iBajas' => $IncluyeBajas,
        ]);

        return $query->queryAll();
    }
}
