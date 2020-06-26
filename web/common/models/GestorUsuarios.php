<?php

namespace common\models;

use Yii;

class GestorUsuarios
{
    /**
     * Permite buscar los usuarios de una empresa dada una cadena de búsqueda, estado (T: todos los estados),
     * Rol (0: todos los roles). Si la cadena de búsqueda es un texto, busca por usuario, apellido
     * y nombre. Para listar todos, cadena vacía.
     * xsp_buscar_usuarios
     *
     */
    public function Buscar($Cadena = '', $Estado = 'A', $IdRol = 0)
    {
        $sql = "call xsp_buscar_usuarios( :host, :cadena, :estado, :rol )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
            ':cadena' => $Cadena,
            ':estado' => $Estado,
            ':rol' => $IdRol,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite modificar un Usuario existente. No se puede cambiar el nombre de usuario, ni la contraseña.
     * Los nombres y apellidos son obligatorios. El correo electrónico no debe existir ya. El rol debe
     * existir. Si se cambia el rol, y se resetea token.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_usuario
     */
    public function Modificar($usuario)
    {
        $sql = "call xsp_modifica_usuario( :token, :idusuario, :idrol, :nombres, :apellidos, :email, "
        . " :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idusuario' => $usuario->IdUsuario,
            ':idrol' => $usuario->IdRol,
            ':nombres' => $usuario->Nombres,
            ':apellidos' => $usuario->Apellidos,
            ':email' => $usuario->Email,
            ':observaciones' => $usuario->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite dar de alta un Usuario controlando que el nombre del usuario no exista ya, siendo nombres y apellidos obligatorios.
     * Se guarda el password hash de la contraseña. El correo electrónico no debe existir ya. El rol debe existir.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_usuario
     */
    public function Alta($usuario)
    {
        $sql = "call xsp_alta_usuario( :token, :idrol, :nombres, :apellidos, :usuario, :password, :email, "
        . " :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrol' => $usuario->IdRol,
            ':nombres' => $usuario->Nombres,
            ':apellidos' => $usuario->Apellidos,
            ':usuario' => $usuario->Usuario,
            ':password' => password_hash($usuario->Password, PASSWORD_BCRYPT),
            ':email' => $usuario->Email,
            ':observaciones' => $usuario->Observaciones,
        ]);

        return $query->queryScalar();
    }
}
