<?php

namespace common\models;

use yii\base\BaseObject;
use common\components\PaypalComponent;
use common\components\Notificaciones;

class SuscripcionesPaypal extends BaseObject implements IOperacionesSuscripciones
{
    /**
     * @var GestorSuscripciones
     */
    public $gestorSuscripciones;
    /**
     * @var PaypalComponent
     */
    public $paypal;
    /**
     * @var Planes
     */
    public $plan;

    public function __construct($config = [])
    {
        if (count($config) === 0) {
            $config = [
                'gestorSuscripciones' => new GestorSuscripciones,
                'paypal' => new PaypalComponent,
                'plan' => new Planes
            ];
        }

        parent::__construct($config);
    }

    /**
     * Proceso de alta de suscripción usando Paypal.
     * Queda en estado pendiente de aprobación.
     * Retorna URL para redirigir al cliente.
     */
    public function Alta($IdPlan, $Codigo)
    {
        $subs = new Suscripciones();
        $subs->IdPlan = $IdPlan;
        $subs->CodigoBonifUsado = $Codigo;
        $subs->Renovar = true;
        $subs->Datos = ['Proveedor' => self::PAYPAL];

        $this->plan->IdPlan = $subs->IdPlan;
        $this->plan->Dame();

        $resultado = $this->gestorSuscripciones->InicioAltaSuscripcion($subs);

        if (substr($resultado, 0, 2) != 'OK') {
            return ['Error' => $resultado];
        }

        $subs->IdSuscripcion = substr($resultado, 2);

        $datos = $this->paypal->crearSuscripcion($subs->IdSuscripcion, $this->plan->Plan);

        // Sp idempotente de alta de suscripción - Guardo datos de paypal
        $subs->Datos['Mensaje'] = $datos;
        $resultado = $this->gestorSuscripciones->InicioAltaSuscripcion($subs);

        if (substr($resultado, 0, 2) != 'OK') {
            return ['Error' => $resultado];
        }

        return ['URL' => $datos['link']];
    }

    /**
     * Finaliza el alta de sucripción en paypal.
     */
    public function Finaliza($subscription_id)
    {
        $mensaje = $this->paypal->obtenerSuscripcion($subscription_id);

        $Datos = [
            'Proveedor' => self::PAYPAL,
            'Tipo' => 'A',
            'Mensaje' => $mensaje
        ];

        $Suscripcion = $this->gestorSuscripciones->DamePorDatos($Datos);

        $resultado = $this->gestorSuscripciones->FinAltaSuscripcion($Datos);

        if (substr($resultado, 0, 2) != 'OK') {
            return ['Error' => $resultado];
        }

        return ['Error' => null];
    }

    public function Cancelar(Suscripciones $Suscripcion, string $Tipo = '')
    {
        if ($Suscripcion->Estado != 'F' && $Tipo != 'W') {
            $resultado = $Suscripcion->InicioDarBaja();
            if (substr($resultado, 0, 2) != 'OK') {
                return ['Error' => $resultado];
            }
        }

        $datos = $Suscripcion->Datos;

        $subscription_id = $datos['Mensaje']['id'];

        $sub = $this->paypal->obtenerSuscripcion($subscription_id);
        if ($sub['status'] != 'CANCELLED') {
            $this->paypal->cancelarSuscripcion($subscription_id);
        }

        $resultado = $Suscripcion->FinDarBaja();
        if (substr($resultado, 0, 2) != 'OK') {
            return ['Error' => $resultado];
        }

        return ['Error' => null];
    }
}
