<?php

namespace common\models;

use Yii;

class GestorRoles
{
    /**
     * Permite dar de alta un Rol controlando que el nombre del rol no exista ya dentro de la misma empresa.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_rol
     */
    public function Alta($rol)
    {
        $sql = "call xsp_alta_rol( :token, :host, :rol, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':host' => Yii::$app->request->headers->get('host'),
            ':rol' => $rol->Rol,
            ':observaciones' => $rol->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar un Rol existente controlando que el nombre del rol no exista ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_rol
     */
    public function Modificar($rol)
    {
        $sql = "call xsp_modifica_rol( :token, :host, :idrol, :rol, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':host' => Yii::$app->request->headers->get('host'),
            ':idrol' => $rol->IdRol,
            ':rol' => $rol->Rol,
            ':observaciones' => $rol->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar los roles dada una cadena de búsqueda y la opción si incluye o no los dados de baja [S|N] respectivamente.
     * Para listar todos, cadena vacía.
     * xsp_buscar_roles
     * 
     */
    public function Buscar($Cadena = '', $IncluyeBajas = 'N')
    {
        $sql = "call xsp_buscar_roles( :host, :cadena, :incluyeBajas )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
            ':cadena' => $Cadena,
            ':incluyeBajas' => $IncluyeBajas,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite borrar un Rol existente y sus permisos asociados controlando que no existan usuarios asociados.
     * No puede borrar roles menores o iguales al 20, reservados para roles del sistema.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_rol
     */
    public function Borrar($rol)
    {
        $sql = "call xsp_borra_rol( :token, :idrol, :rol, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrol' => $rol->IdRol,
            ':rol' => $rol->Rol,
            ':observaciones' => $rol->Observaciones,
        ]);

        return $query->queryScalar();
    }
}