<?php

namespace common\models;

use Yii;

class GestorDestinosCheque
{
    /**
     * Permite dar de alta un destino de cheque controlando que el nombre del destino no exista ya.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_destino_cheque
     */
    public function Alta(DestinosCheque $destino)
    {
        $sql = "call xsp_alta_destino_cheque( :token, :idempresa, :destino, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':destino' => $destino->Destino,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar un DestinoCheque.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_destino_cheque
     */
    public function Modificar(DestinosCheque $destino)
    {
        $sql = "call xsp_modifica_destino_cheque( :token, :iddestino, :destino, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':iddestino' => $destino->IdDestinoCheque,
            ':destino' => $destino->Destino,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar los destinos de cheque dada una cadena de búsqueda, y el estado (T para listar todos).
     * Para listar todos, cadena vacía.
     * xsp_buscar_destinos_cheque
     */
    public function Buscar($Cadena = '', $Estado = 'A')
    {
        $sql = "call xsp_buscar_destinos_cheque( :idempresa, :cadena, :estado )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena,
            ':estado' => $Estado,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite borrar un destino controlando que no tenga cheques asosiados.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_destino_cheque
     */
    public function Borrar(DestinosCheque $destino)
    {
        $sql = "call xsp_borra_destino_cheque( :token, :idestno, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idestno' => $destino->IdDestinoCheque,
        ]);

        return $query->queryScalar();
    }
}
