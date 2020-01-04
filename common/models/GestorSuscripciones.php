<?php
namespace common\models;

use Yii;

class GestorSuscripciones
{
    /**
     * Registra el inicio del proceso de suscripcion del usuario. Si existe una suscripción Activa para el Usuario, retorna un mensaje de error.
     * Si existe una suscripción Pendiente para el Usuario, actualiza las fechas de inicio y fin y los datos json, retorna OK+Id.
     * En otro caso devuelve OK+Id o el mensaje de error en Mensaje.
     *
     * @param Suscripcion
     */
    public function InicioAltaSuscripcion(Suscripciones $Suscripcion)
    {
        $sql = "CALL xsp_inicio_alta_suscripcion(:token, :IdPlan, :Renovar, :CodigoBonif, :datos, :IP, :UserAgent, :Aplicacion)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':token' => Yii::$app->user->Identity->Token,
            ':IdPlan' => $Suscripcion->IdPlan,
            ':Renovar' => $Suscripcion->Renovar ? 'S': 'N',
            ':CodigoBonif' => $Suscripcion->CodigoBonifUsado,
            ':datos' => isset($Suscripcion->Datos) ? json_encode($Suscripcion->Datos) : null,
            ':IP' => Yii::$app->request->userIP,
            ':UserAgent' => Yii::$app->request->userAgent,
            ':Aplicacion' => Yii::$app->id,
        ]);

        return $query->queryScalar();
    }

    /**
     * Hace efectiva la aprobacion de la suscripcion elegida. Devuelve OK+Id o el mensaje de error en Mensaje.
     *
     * @param Datos Datos JSON de la suscripción en Paypal
     */
    public function FinAltaSuscripcion($Datos = '')
    {
        $sql = "CALL xsp_fin_alta_suscripcion(:datos)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':datos' => json_encode($Datos)
        ]);

        return $query->queryScalar();
    }

    /**
     * Instancia una suscripcion por datos.
     *
     * @param Datos Datos JSON de la suscripción en Paypal
     */
    public function DamePorDatos($Datos = '')
    {
        $Suscripcion = new Suscripciones;
        $Suscripcion->Datos = $Datos;
        $Suscripcion->DamePorDatos();
        return $Suscripcion;
    }

    /**
     * Permite obtener todas las suscripciones del usuario indicado.
     */
    public function HistorialSuscripcionesUsuario()
    {
        $sql = "CALL xsp_dame_suscripciones_usuario(:usuario)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':usuario' => Yii::$app->user->identity->IdEmpresa,
        ]);

        return $query->queryAll();
    }
}
