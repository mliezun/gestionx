<?php
namespace common\models;

use Yii;

class GestorEmpresas
{
    /**
     * Permite dar de alta una nueva empresa, junto con todos los parámetros de empresa por defecto.
     * Verifica que el nombre de la empresa no exista ya.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_empresa
     *
     */
    public function Alta(EmpresasModel $Empresa)
    {
        $sql = "call xsp_alta_empresa( :token, :empresa, :url, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':empresa' => $Empresa->Empresa,
            ':url' => $Empresa->URL
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar empresas por una Cadena de búsqueda indicando si se incluyen o no las
     * dadas de baja. Cadena vacía para listar todas.
     * xsp_buscar_empresas
     *
     */
    public function Buscar(string $Cadena = '', string $IncluyeBajas = 'N')
    {
        $sql = "call xsp_buscar_empresas( :cadena, :bajas )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':cadena' => $Cadena,
            ':bajas' => $IncluyeBajas
        ]);

        return $query->queryAll();
    }
}
