<?php

namespace common\models;

use Yii;

class GestorProveedores
{
    /**
     * Permite dar de alta un proveedor. Controlando que el nombre del proveedor no exista ya
     * dentro de la misma empresa. Devuelve OK+Id o el mensaje de error en Mensaje.
     * xsp_alta_proveedor
     * 
     */
    public function Alta(Proveedores $Proveedor)
    {
        $sql = "call xsp_alta_proveedor( :token, :idempresa, :proveedor, :descuento, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':descuento' => $Proveedor->Descuento,
            ':proveedor' => $Proveedor->Proveedor
        ]);

        return $query->queryScalar();
    }
    /**
     * Permite buscar proveedores dentro de una empresa indicando una cadena de búsqueda
     * y si se incluyen bajas.
     * xsp_buscar_proveedores
     * 
     */
    public function Buscar($Cadena = '', $IncluyeBajas = 'N')
    {
        $sql = "call xsp_buscar_proveedores( :idempresa, :cadena, :iBajas )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena,
            ':iBajas' => $IncluyeBajas,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite cambiar el nombre de un proveedor, verificando que no exista uno igual dentro
     * de la misma empresa. Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_proveedor
     */
    public function Modificar(Proveedores $Proveedor)
    {
        $sql = "call xsp_modifica_proveedor( :token, :idproveedor, :proveedor, :descuento, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idproveedor' => $Proveedor->IdProveedor,
            ':descuento' => $Proveedor->Descuento,
            ':proveedor' => $Proveedor->Proveedor
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite borrar un proveedor controlando que no tenga artículos asociados.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_proveedor
     */
    public function Borrar(Proveedores $Proveedor)
    {
        $sql = "call xsp_borra_proveedor( :token, :idproveedor, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idproveedor' => $Proveedor->IdProveedor
        ]);

        return $query->queryScalar();
    }
}