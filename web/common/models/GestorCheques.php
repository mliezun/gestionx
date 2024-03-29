<?php

namespace common\models;

use common\helpers\FechaHelper;
use Yii;

class GestorCheques
{
    /**
     * Permite dar de alta un Cheque.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_cheque
     */
    public function Alta(Cheques $cheque)
    {
        $sql = "call xsp_alta_cheque( :token, :idcliente, :idbanco, :iddestino, :nrocheque, :importe,
        :fechavenc, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcliente' => $cheque->IdCliente,
            ':idbanco' => $cheque->IdBanco,
            ':iddestino' => ($cheque->IdDestinoCheque == '') ? null : $cheque->IdDestinoCheque,
            ':nrocheque' => $cheque->NroCheque,
            ':importe' => $cheque->Importe,
            ':fechavenc' => FechaHelper::formatearDateMysql($cheque->FechaVencimiento),
            ':observaciones' => $cheque->Obversaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar un Cheque.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_cheque
     */
    public function Modificar(Cheques $cheque)
    {
        $sql = "call xsp_modifica_cheque( :token, :idcheque, :idcliente, :idbanco, :iddestino, :nrocheque, :importe,
        :fechavenc, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcheque' => $cheque->IdCheque,
            ':idcliente' => $cheque->IdCliente,
            ':idbanco' => $cheque->IdBanco,
            ':iddestino' => ($cheque->IdDestinoCheque == '') ? null : $cheque->IdDestinoCheque,
            ':nrocheque' => $cheque->NroCheque,
            ':importe' => $cheque->Importe,
            ':fechavenc' => FechaHelper::formatearDateMysql($cheque->FechaVencimiento),
            ':observaciones' => $cheque->Obversaciones,
        ]);

        return $query->queryScalar();
    }

    /*
     * Permite buscar los cheques dada una cadena de búsqueda, el tipo de cheque (T: para listar todas, C: clientes, P: propios),
     * el estado y una fecha de inicio y fin.
     * Para listar todos, cadena vacía.
     * xsp_buscar_cheques
     *
     */
    public function Buscar($Cadena = '', $FechaInicio = '', $FechaFin = '', $Estado = 'D', $Tipo = 'T', $IdCliente = null)
    {
        $sql = "call xsp_buscar_cheques( :idempresa, :cadena, :fi, :ff, :estado, :tipo, :IdCliente )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena,
            ':fi' => FechaHelper::formatearDateMysql($FechaInicio),
            ':ff' => FechaHelper::formatearDateMysql($FechaFin),
            ':estado' => $Estado,
            ':tipo' => $Tipo,
            ':IdCliente' => $IdCliente,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite borrar un cheque controlando que no tenga pagos asosiados.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_cheque
     */
    public function Borrar(Cheques $cheque)
    {
        $sql = "call xsp_borra_cheque( :token, :idcheque, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcheque' => $cheque->IdCheque,
        ]);

        return $query->queryScalar();
    }
}
