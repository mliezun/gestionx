<?php

namespace common\models;

use Yii;

class GestorRemitos
{
    /**
     * Permite dar de alta un Remito controlando que el nro de remito no exista ya dentro del mismo proveedor.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_remito
     */
    public function Alta(Remitos $remito, $PuntoVenta)
    {
        $sql = "call xsp_alta_remito( :token, :idempresa, :idproveedor, :idpuntoventa, :idcanal,
        :nroremito, :cai, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idproveedor' => $remito->IdProveedor,
            ':idcanal' => $remito->IdCanal,
            ':idpuntoventa' => $PuntoVenta,
            ':nroremito' => $remito->NroRemito,
            ':cai' => $remito->CAI == "" ? NULL : $remito->CAI,
            ':observaciones' => $remito->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar un Remito existente controlando que el nroremito no exista ya dentro del mismo proveedor.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_remito
     */
    public function Modificar($remito)
    {
        $sql = "call xsp_modifica_remito( :token, :idremito, :idempresa, :idproveedor, :idcanal, :nroremito, :cai, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idremito' => $remito->IdRemito,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idproveedor' => $remito->IdProveedor,
            ':idcanal' => $remito->IdCanal,
            ':nroremito' => $remito->NroRemito,
            ':cai' => $remito->CAI == "" ? NULL : $remito->CAI,
            ':observaciones' => $remito->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar los remitos dada una cadena de búsqueda y estado (T: todos los estados)
     * Para listar todos, cadena vacía.
     * xsp_buscar_remito
     */
    public function Buscar($PuntoVenta = 0, $Cadena = '', $Estado = 'E', $Proveedor = 0, $Canal = 0, $IncluyeUtilizados = 'S')
    {
        $sql = "call xsp_buscar_remitos( :idempresa, :cadena, :estado , :proveedor, :puntoventa, :canal , :incluye)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena,
            ':estado' => $Estado,
            ':proveedor' => $Proveedor,
            ':puntoventa' => $PuntoVenta,
            ':canal' => $Canal,
            ':incluye' => $IncluyeUtilizados,
        ]);

        return $query->queryAll();
    }
}
