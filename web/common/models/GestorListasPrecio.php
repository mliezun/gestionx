<?php

namespace common\models;

use Yii;

class GestorListasPrecio
{
    /**
     * Permite dar de alta una lista de precios controlando que el nombre de la lista no exista ya dentro de la misma empresa.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_lista_precio
     */
    public function Alta(ListasPrecio $lista)
    {
        $sql = "call xsp_alta_lista_precio( :token, :idempresa, :lista, :porcentaje, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':lista' => $lista->Lista,
            ':porcentaje' => $lista->Porcentaje,
            ':observaciones' => $lista->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar una Lista de precios existente controlando que el nombre de la lista no exista ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_lista_precio
     */
    public function Modificar(ListasPrecio $lista)
    {
        $sql = "call xsp_modifica_lista_precio( :token, :idlista, :lista, :porcentaje, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idlista' => $lista->IdListaPrecio,
            ':lista' => $lista->Lista,
            ':porcentaje' => $lista->Porcentaje,
            ':observaciones' => $lista->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite borrar un Rol existente y sus permisos asociados controlando que no existan usuarios asociados.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_lista_precio
     */
    public function Borrar(ListasPrecio $lista)
    {
        $sql = "call xsp_borra_lista_precio( :token, :idlista, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idlista' => $lista->IdListaPrecio,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar listas de precios dentro de una empresa, indicando una cadena de búsqueda
     * y si se incluyen bajas.
     * xsp_buscar_listas_precio
     */
    public function Buscar($IncluyeDefecto = 'N', $Cadena = '', $IncluyeBajas = 'N')
    {
        $sql = "call xsp_buscar_listas_precio( :idempresa, :cadena, :iBajas, :iDefecto)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena,
            ':iBajas' => $IncluyeBajas,
            ':iDefecto' => $IncluyeDefecto,
        ]);

        return $query->queryAll();
    }
}
