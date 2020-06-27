<?php

namespace common\models;

use Yii;

class GestorTiposGravamenes
{
    /**
     * Permite dar de alta un proveedor. Controlando que el nombre del proveedor no exista ya
     * dentro de la misma empresa. Devuelve OK+Id o el mensaje de error en Mensaje.
     * xsp_alta_proveedor
     *
     */
    public function Alta(TiposGravamenes $TipoGravamen)
    {
        $sql = "call xsp_alta_tipogravamen( :token, :tipogravamen, :gravamen, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':tipogravamen' => $TipoGravamen->TipoGravamen,
            ':gravamen' => $TipoGravamen->Gravamen
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
        $sql = "call xsp_buscar_tiposgravamenes( :idempresa, :cadena, :iBajas )";

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
    public function Modificar(TiposGravamenes $TipoGravamen)
    {
        $sql = "call xsp_modifica_tipogravamen( :token, :idTipoGravamen, :TipoGravamen, :Gravamen , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idTipoGravamen' => $TipoGravamen->IdTipoGravamen,
            ':TipoGravamen' => $TipoGravamen->TipoGravamen,
            ':Gravamen' => $TipoGravamen->Gravamen
        ]);

        return $query->queryScalar();
    }
}
