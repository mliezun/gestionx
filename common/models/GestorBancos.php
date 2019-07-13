<?php

namespace common\models;

use Yii;

class GestorBancos
{
    /**
     * Permite dar de alta un Cliente.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_banco
     */
    public function Alta(Bancos $banco)
    {
        $sql = "call xsp_alta_banco( :token, :idempresa, :banco, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':banco' => $banco->Banco,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar un Cliente.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_banco
     */
    public function Modificar(Bancos $banco)
    {
        $sql = "call xsp_modifica_banco( :token, :idbanco, :banco, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idbanco' => $banco->IdBanco,
            ':banco' => $banco->Banco,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar los bancos dada una cadena de búsqueda, el tipo de banco (T para listar todas)
     * y la opción si incluye o no los dados de baja [S|N] respectivamente.
     * Para listar todos, cadena vacía.
     * xsp_buscar_bancos
     * 
     */
    public function Buscar($Cadena = '', $Estado = 'A')
    {
        $sql = "call xsp_buscar_bancos( :idempresa, :cadena, :estado )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena,
            ':estado' => $Estado,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite borrar un banco controlando que no tenga ventas asosiadas.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_banco
     */
    public function Borrar(Bancos $banco)
    {
        $sql = "call xsp_borra_banco( :token, :idbanco, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idbanco' => $banco->IdBanco,
        ]);

        return $query->queryScalar();
    }
}