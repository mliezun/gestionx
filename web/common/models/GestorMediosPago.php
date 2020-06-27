<?php

namespace common\models;

use Yii;

class GestorMediosPago
{
    public function Listar()
    {
        $sql = "call xsp_listar_mediospago( )";

        $query = Yii::$app->db->createCommand($sql);

        return $query->queryAll();
        /*$mediospago = array();

        foreach($this->Buscar() as $mediopago) {
            $mediospago[$mediopago['IdMedioPago']] = MediosPago::Nombre($mediopago);
        }

        return $clientes;*/
    }
}
