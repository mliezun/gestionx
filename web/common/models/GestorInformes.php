<?php

namespace common\models;

use Yii;

class GestorInformes
{
    /**
     * Permite listar las tablas del sistema.
     */
    public function ListarTablas($Schema = 'gestionx')
    {
        $sql = 'CALL xsp_listar_tablas( :Schema )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':Schema' => $Schema
        ]);
        
        return json_decode($query->queryScalar(), true);
    }
}
