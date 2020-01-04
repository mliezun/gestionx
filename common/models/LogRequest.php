<?php

namespace common\models;

use Yii;

class LogRequest
{

    /**
     * Permite loguear un pedido a un Endpoint.
     * xsp_log_request
     */
    public static function Log($Endpoint, $Datos)
    {
        $sql = 'CALL xsp_log_request( :Endpoint, :Datos )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':Endpoint' => $Endpoint,
            ':Datos' => json_encode($Datos)
        ]);

        return $query->queryScalar();
    }
}