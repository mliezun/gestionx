<?php
namespace common\models;

use Yii;
use yii\base\Model;

class Roles extends Model
{
    public $IdRol;
    public $Rol;
    public $Estado;
    public $Observaciones;
    public $IdEmpresa;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    const SCENARIO_CLONAR = 'clonar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja',
        'T' => 'Todos'
    ];
 
    public function rules()
    {
        return [
            [['Rol'],
                'required', 'on' => self::_ALTA],
            [['IdRol', 'Rol'],
                'required', 'on' => self::_MODIFICAR],
            // Clonar
            [['IdRol', 'Rol'], 'required', 'on' => self::SCENARIO_CLONAR],
            [['IdRol', 'Rol', 'Estado', 'Observaciones','IdEmpresa'], 'safe']
        ];
    }

    /**
     * Permite instanciar un rol desde la base de datos.
     * xsp_dame_rol
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_rol( :idRol )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idRol' => $this->IdRol
        ]);
        
        $this->attributes = $query->queryOne();
    }

    /**
     * Permite cambiar el estado del Rol a Activo siempre y cuando no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_rol
     */
    public function Activa()
    {
        $sql = "call xsp_activar_rol( :token, :idrol, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrol' => $this->IdRol,
            ':observaciones' => $this->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del Rol a Baja siempre y cuando no esté dado de baja y no existan
     * usuarios activos asociados.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_rol
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_rol( :token, :idrol, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idrol' => $this->IdRol,
            ':observaciones' => $this->Observaciones,
        ]);

        return $query->queryScalar();
    }


    /**
     * Permite clonar un rol a partir de un existente, pas�ndole el nombre,
     * controlando que no exista ya.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_clonar_rol
     *
     * @param NombreNuevo    NombreNuevo
     */
    public function Clonar($NombreNuevo)
    {
        $sql = "CALL xsp_clonar_rol ( :token, :id, :nombre, :IP , :userAgent , :app ) ";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $this->IdRol,
            ':nombre' => $NombreNuevo,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite escribir la clave del elemento
     *
     * @param nuevoId
     */
    public function setId($nuevoId)
    {
        $this->IdRol = $nuevoId;
    }

    /**
     * Devuelve la clave del elemento
     */
    public function getId()
    {
        return $this->IdRol;
    }

    /**
     * Permite escribir el nombre del elemento
     *
     * @param nuevoNombre
     */
    public function setNombre($nuevoNombre)
    {
    }

    /**
     * Devuelve el nombre del elemento
     */
    public function getNombre()
    {
        return $this->Rol;
    }

    /**
     * Lista todos los permisos existentes, adjuntándoles un campo estado cuyo valor
     * es [S|N|G], S: tiene permiso, N: no tiene permiso, G: agrupa permisos. Adjunta
     * otro campo si dice si es o no permiso hoja (EsHoja = [S|N]). Los permisos están
     * listados en orden jerárquico y arbóreo, con el nodo padre, el nivel del árbol y
     * una cadena para mostrarlo ordenado. xsp_listar_permisos_rol
     */
    public function ListarPermisos()
    {
        $sql = "CALL xsp_listar_permisos_rol ( :id ) ";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValue(':id', $this->IdRol);

        return $query->queryAll();
    }

    /**
     * Dado el rol y una cadena formada por la lista de los IdPermisos separados por
     * comas, asigna los permisos seleccionados como dados y quita los no dados. Los
     * asigna siempre y cuando los permisos sean hoja. Cambia el token de los usuarios
     * del rol as� deban reiniciar sesión y retomar permisos. Devuelve OK o el mensaje
     * de error en Mensaje. xsp_asignar_permisos_rol
     *
     * @param listapermisos
     * @param Motivo    Motivo de auditor�a
     * @param Autoriza    Usuario que autoriza
     */
    public function AsignarPermisos($listapermisos)
    {
        $sql = "CALL xsp_asignar_permisos_rol ( :token, :id, :lista, :IP , :userAgent , :app, :motivo, :autoriza )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $this->IdRol,
            ':lista' => "[$listapermisos]",
            ':motivo' => '',
            ':autoriza' => '',
        ]);

        return $query->queryScalar();
    }
}
