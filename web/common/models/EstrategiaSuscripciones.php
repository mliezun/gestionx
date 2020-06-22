<?php

namespace common\models;

use yii\web\HttpException;

class EstrategiaSuscripciones implements IOperacionesSuscripciones
{
    private $Proveedor;
    public $Estrategias;

    public function __construct($Proveedor = '')
    {
        $this->Proveedor = $Proveedor;
        $this->Estrategias = [
            self::PAYPAL => new SuscripcionesPaypal
        ];
    }

    public function setProveedor($Proveedor = '')
    {
        $this->Proveedor = $Proveedor;
        return $this;
    }

    private function obtenerEstrategia()
    {
        if (!array_key_exists($this->Proveedor, $this->Estrategias)) {
            throw new HTTPException(400, 'Bad Request');
        }

        return $this->Estrategias[$this->Proveedor];
    }


    /**
     * Alta de Suscripción Idempotente.
     */
    public function Alta($IdPlan, $Codigo)
    {
        return $this->obtenerEstrategia()->Alta($IdPlan, $Codigo);
    }

    /**
     * Finalización de Suscripción Idempotente.
     */
    public function Finaliza($subscription_id)
    {
        return $this->obtenerEstrategia()->Finaliza($subscription_id);
    }

    /**
     * Cancelación de Suscripción Idempotente.
     */
    public function Cancelar(Suscripciones $Suscripcion, String $Tipo = '')
    {
        return $this->obtenerEstrategia()->Cancelar($Suscripcion, $Tipo);
    }
}
