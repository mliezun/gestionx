<?php
namespace common\models;

use Yii;

class GestorPlanes
{
    /**
     * Da de alta un nuevo plan de suscripcion. Devuelve OK+Id o el mensaje de error en Mensaje.
     * xsp_alta_plan
     *
     * @param Plan Nombre del Plan
     * @param Dias Cantidad de días PREMIUM que otorgará el plan
     * @param Precio Costo del plan
     * @param Descripcion Descripcion del Plan, opcional
     */
    public function Alta(Planes $Plan)
    {
        $sql = "CALL xsp_alta_plan(:Plan, :Dias, :Precio, :Descripcion)";
        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':Plan' => $Plan->Plan,
            ':Dias' => $Plan->CantDias,
            ':Precio' => $Plan->Precio,
            ':Descripcion' => $Plan->Descripcion,
        ]);

        return $query->queryScalar();
    }

    /**
     * Devuelve listado de los planes, filtrando por estado.
     * xsp_listar_planes
     * 
     * @param Estado Filtro de Estado del Plan
     */
    public function ListarPlanes($Estado = 'A')
    { 
        $sql = "CALL xsp_listar_planes(:Estado)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':Estado' => $Estado,
        ]);

        return $query->queryAll();
    }
}
