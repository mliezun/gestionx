<?php
namespace common\models;

use Yii;
use yii\base\Model;
use yii\web\IdentityInterface;

class Usuarios extends Model implements IdentityInterface
{
    public $IdUsuario;
    public $IdRol;
    public $Nombres;
    public $Apellidos;
    public $Usuario;
    public $Password;
    public $Token;
    public $Email;
    public $IntentosPass;
    public $FechaUltIntento;
    public $FechaAlta;
    public $DebeCambiarPass;
    public $Estado;
    public $Observaciones;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    const _LOGIN =  'login';
    
    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja',
        'S' => 'Suspendido'
    ];
    
    public function attributeLabels()
    {
        return [
            'IdRol' => 'Rol'
        ];
    }
 
    public function rules()
    {
        return [
            ['Email','email'],
            [['Usuario', 'Password'], 'required', 'on' => self::_LOGIN],
            [['IdRol', 'Nombres', 'Apellidos', 'Usuario', 'Email'],
                'required', 'on' => self::_ALTA],
            [['IdUsuario', 'IdRol', 'Nombres', 'Apellidos', 'Usuario', 'Email', 'Password'],
                'required', 'on' => self::_MODIFICAR],
            [['IdUsuario', 'IdRol', 'Nombres', 'Apellidos', 'Usuario',
                'Token', 'Email', 'DebeCambiarPass', 'Estado', 'Observaciones'], 'safe']
        ];
    }

    /**
     * Finds an identity by the given ID.
     * @param string|int $id the ID to be looked for
     * @return IdentityInterface the identity object that matches the given ID. Null
     * should be returned if such an identity cannot be found or the identity is not
     * in an active state (disabled, deleted, etc.)
     *
     * @param id
     */
    public static function findIdentity($id)
    {
        $usuario = new Usuarios();
        
        $usuario->IdUsuario = $id;
        
        $usuario->Dame();
        
        return $usuario;
    }

    /**
     * Finds an identity by the given token.
     * @param mixed $token the token to be looked for
     * @param mixed $type the type of the token. The value of this parameter depends
     * on the implementation. For example, [[\yii\filters\auth\HttpBearerAuth]] will
     * set this parameter to be `yii\filters\auth\HttpBearerAuth`.
     * @return IdentityInterface the identity object that matches the given token.
     * Null should be returned if such an identity cannot be found or the identity is
     * not in an active state (disabled, deleted, etc.)
     *
     * @param token
     * @param type
     */
    public static function findIdentityByAccessToken($token, $type = null)
    {
        $usuario = new Usuarios();
        
        $usuario->Token = $token;
        
        $usuario->DamePorToken();
        
        if ($usuario->IdUsuario != null) {
            return $usuario;
        } else {
            return null;
        }
    }

    /**
     * Returns an ID that can uniquely identify a user identity.
     * @return string|int an ID that uniquely identifies a user identity.
     */
    public function getId()
    {
        return $this->IdUsuario;
    }

    /**
     * Returns a key that can be used to check the validity of a given identity ID.
     * The key should be unique for each individual user, and should be persistent so
     * that it can be used to check the validity of the user identity.  The space of
     * such keys should be big enough to defeat potential identity attacks.  This is
     * required if [[User::enableAutoLogin]] is enabled.
     * @return string a key that is used to check the validity of a given identity ID.
     *
     * @see validateAuthKey()
     */
    public function getAuthKey()
    {
        return $this->Token;
    }

    /**
     * Validates the given auth key.  This is required if [[User::enableAutoLogin]] is
     * enabled.
     * @param string $authKey the given auth key
     * @return bool whether the given auth key is valid.
     * @see getAuthKey()
     *
     * @param authKey
     */
    public function validateAuthKey($authKey)
    {
        return $this->getAuthKey() === $authKey;
    }

    /**
     * Permite instanciar un usuario desde la base de datos.
     * xsp_dame_usuario
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_usuario( :idUsuario )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idUsuario' => $this->IdUsuario
        ]);
        
        $this->attributes = $query->queryOne();
    }
    
    /**
     * Permite instanciar un usuario por Usuario desde la base de datos.
     * xsp_dame_usuario_por_usuario
     */
    public function DamePorUsuario()
    {
        $sql = 'CALL xsp_dame_usuario_por_usuario( :usuario )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':usuario' => $this->Usuario
        ]);
        
        $this->attributes = $query->queryOne();
    }

    /**
     * Permite cambiar el estado de un usuario a Activo. Devuelve OK o un mensaje de
     * error en Mensaje. xsp_activar_usuario
     */
    public function Activar()
    {
        $sql = "CALL xsp_activar_usuario ( :token, :id, :IP, :userAgent, :app )";
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $this->IdUsuario
        ]);
        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado de un usuario a Baja. Devuelve OK o un mensaje de
     * error en Mensaje. xsp_darbaja_usuario
     */
    public function DarBaja()
    {
        $sql = "CALL xsp_darbaja_usuario ( :token, :id, :IP, :userAgent, :app )";
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $this->IdUsuario
        ]);
        return $query->queryScalar();
    }

    /**
     * Permite instanciar un usuario desde la base de datos a partir del token de
     * sesi�n. xsp_dame_usuario_por_token
     */
    public function DamePorToken()
    {
        $sql = 'CALL xsp_dame_usuario_por_token( :token )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => $this->Token
        ]);
        
        $res = $query->queryOne();
        
        $this->attributes = $res;
        
        return $res;
    }

    /**
     * Permite obtener el password hash de un usuario a partir del nombre de usuario.
     * xsp_dame_password_hash
     */
    public function DamePassword()
    {
        $sql = "CALL xsp_dame_password_hash ( :usuario )";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValue(':usuario', $this->Usuario);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar la contrase�a por el hash recibido como par�metro. Al recibir
     * un hash no puede controlarse que cumpla con las pol�ticas de contrase�as. El
     * token debe ser de un cliente existente, en estado activo. Cuando pModo = U,
     * debe pasar el token de sesi�n, el usuario debe existir, estar activo y debe
     * ingresar la contrase�a anterior. Devuelve OK o el mensaje de error en Mensaje.
     * Cuando pModo = R, se utiliza para rehash. Debe pasar el token de sesi�n, el
     * usuario debe existir, estar activo. S�lo actualiza hash en la tabla Usuarios
     * sin agregar al historial. Devuelve OK o el mensaje de error en Mensaje.
     * xsp_cambiar_password
     *
     * @param Token
     * @param OldPass
     * @param NewPass
     * @param Modo    U : Usuario - C: Cliente - R: ReHash
     */
    public function CambiarPassword($Token = null, $OldPass = null, $NewPass = null, $Modo = 'U')
    {
        if ($Modo != 'R') {
            // Verifico que el password cumpla con las políticas de contraseña
//            $esValida = $this->EsPasswordValida($NewPass);
//            if ($esValida != 'OK') {
//                return $esValida;
//            }

            // Verifico que el password anterior sea correcto
            $hash = $this->DamePassword();

            if (!(strlen($hash) == 32 && $hash == md5($OldPass)) && !password_verify($OldPass, $hash)) {
                return 'No se puede cambiar la contraseña. La contraseña anterior es incorrecta.';
            }
        }

        $newHash = password_hash($NewPass, PASSWORD_DEFAULT);

        $sql = "CALL xsp_cambiar_password( :modo, :token, :passwordNuevo, :IP, :userAgent, :aplicacion)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':modo' => $Modo,
            ':token' => $Token,
            ':passwordNuevo' => $newHash,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':aplicacion' => Yii::$app->id,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite devolver en un resultset la lista de variables de permiso que el
     * usuario tiene habilitados. Se valida con el token de sesi�n.
     * xsp_dame_permisos_usuario
     */
    public function DamePermisos()
    {
        $sql = 'CALL xsp_dame_permisos_usuario ( :token )';

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValue(':token', $this->Token);

        return $query->queryColumn();
    }
    
    /**
     * Permite validar el c�digo de verificaci�n enviado al usuario en el frontend.
     * Actualiza el Token del usuario y devuelve el password hash.
     * xsp_validar_codigo
     *
     * @param Codigo    C�digo de verificaci�n
     */
    public function ValidarCodigo($Codigo = null)
    {
        $hash = $this->DamePassword();
        
        if (password_verify($Codigo, $hash)) {
            $EsValido = 'S';
        } else {
            $EsValido = 'N';
        }
        
        $sql = 'CALL xsp_validar_codigo( :usuario, :esValido,'
                . ' :IP, :userAgent, :app )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':usuario' => $this->Usuario,
            ':esValido' => $EsValido,
        ]);
        
        return $query->queryScalar();
    }

    /**
     * Permite realizar el login de un usuario indicando la aplicaci�n a la que desea
     * acceder en pApp= A: Administraci�n, C: Cliente - E: Estudios. Recibe como par�metro la
     * autenticidad del par Usuario - Password en pEsPassValido [S | N]. Controla que
     * el usuario no haya superado el l�mite de login's erroneos posibles indicado en
     * MAXINTPASS, caso contrario se cambia El estado de la cuenta a S: Suspendido. Un
     * intento exitoso de inicio de sesi�n resetea el contador de intentos fallidos.
     * Devuelve un mensaje con el resultado del login y un objeto usuario en caso de
     * login exitoso. xsp_login
     *
     * @param App    A: Administraci�n - C: Cliente
     * @param Pass    Passwrod del usuario
     * @param Token
     */
    public function Login($App = '', $Pass = null, $Token = null)
    {
        $hash = $this->DamePassword();

        $necesitaRehash = false;

        // El usuario tiene hash en MD5 y coincide con el password ingresado
        if (strlen($hash) == 32 && $hash == md5($Pass)) {
            $necesitaRehash = true;
            $esValido = 'S';
        } elseif (password_verify($Pass, $hash)) {
            $esValido = 'S';
            // Si es necesario rehash
            if (password_needs_rehash($hash, PASSWORD_DEFAULT)) {
                $necesitaRehash = true;
            }
        } else {
            $esValido = 'N';
        }

        $sql = "CALL xsp_login( :usuario, :esValido, :token, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => $App,
            ':usuario' => $this->Usuario,
            ':esValido' => $esValido,
            ':token' => $Token
        ]);

        $result = $query->queryOne();

        $this->attributes = $result;
        if ($necesitaRehash && $result['Mensaje'] == 'OK') {
            $this->CambiarPassword($this->Token, null, $Pass, 'R');
        }

        return $result;
    }
    
    public function ExisteUsuario()
    {
        $sql = 'CALL xsp_existe_usuario( :usuario )';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':usuario' => $this->Usuario
        ]);
        
        return $query->queryScalar();
    }
}
