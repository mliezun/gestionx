<?php

namespace common\models;

use Yii;

class GestorCanales
{
    /**
     * Permite dar de alta un canal controlando que el nombre del canal no exista ya dentro de la misma empresa.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_canal
     */
    public function Alta(Canales $canal)
    {
        $sql = "call xsp_alta_canal( :token, :idempresa, :canal, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':canal' => $canal->Canal,
            ':observaciones' => $canal->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar un Canal existente controlando que el nombre del Canal no exista ya dentro de la misma empresa.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_canal
     */
    public function Modificar(Canales $canal)
    {
        $sql = "call xsp_modifica_canal( :token, :id, :canal, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $canal->IdCanal,
            ':canal' => $canal->Canal,
            ':observaciones' => $canal->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite borrar un Canal existente controlando que no existan remitos,
     * ventas o rectificaciones asociadas.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_canal
     */
    public function Borrar(Canales $canal)
    {
        $sql = "call xsp_borra_canal( :token, :id, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $canal->IdCanal,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar canales dentro de una empresa, indicando una cadena de búsqueda
     * y si se incluyen bajas.
     * xsp_buscar_canales
     */
    public function Buscar($Cadena = '', $IncluyeBajas = 'N', $IdEmpresa = null)
    {
        $sql = "call xsp_buscar_canales( :idempresa, :cadena, :iBajas)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => $IdEmpresa ?? Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena,
            ':iBajas' => $IncluyeBajas,
        ]);

        return $query->queryAll();
    }
}
