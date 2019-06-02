<?php

namespace common\models;

use Yii;

class GestorPuntosVenta
{
    /**
     * Permite dar de alta un Punto Venta controlando que el nombre del Punto Venta no exista ya dentro de la misma empresa.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_puntoventa
     */
    public function Alta($puntoventa)
    {
        $sql = "call xsp_alta_puntoventa( :token, :host, :puntoventa, :datos, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':host' => Yii::$app->request->headers->get('host'),
            ':puntoventa' => $puntoventa->PuntoVenta,
            ':datos' => $puntoventa->Datos,
            ':observaciones' => $puntoventa->Observaciones,
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
     * Permite buscar los roles dada una cadena de búsqueda y estado (T: todos los estados)
     * Para listar todos, cadena vacía.
     * xsp_buscar_roles
     * 
     */
    public function Buscar($Cadena = '', $Estado = 'A')
    {
        $sql = "call xsp_buscar_roles( :host, :cadena, :estado )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
            ':cadena' => $Cadena,
            ':estado' => $Estado,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite borrar un Rol existente y sus permisos asociados controlando que no existan usuarios asociados.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_rol
     */
    public function Borrar($rol)
    {
        $sql = "call xsp_borra_rol( :token, :idrol, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrol' => $rol->IdRol,
            ':observaciones' => $rol->Observaciones,
        ]);

        return $query->queryScalar();
    }
}