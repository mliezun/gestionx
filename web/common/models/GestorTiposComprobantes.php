<?php

namespace common\models;

use Yii;

class GestorTiposComprobantes
{
    public function Listar()
    {
        $sql = "call xsp_listar_tiposcomprobante( )";

        $query = Yii::$app->db->createCommand($sql);

        return $query->queryAll();
    }
}
