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

    /**
     * Permite listar los medios de pago activos para un tipo de entidad pagable determinada.
     * xsp_buscar_mediospago
     *
     */
    public function Buscar($Tipo = 'T')
    {
        $sql = "call xsp_buscar_mediospago( :tipo )";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':tipo' => $Tipo,
        ]);

        return $query->queryAll();
    }
}
