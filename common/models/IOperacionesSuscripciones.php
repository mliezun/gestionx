<?php

namespace common\models;

interface IOperacionesSuscripciones
{
    const PAYPAL = 'Paypal';
    const GOOGLE = 'Google';
    const TESTER = 'Tester';

    public function Alta($IdPlan, $Codigo);
    public function Finaliza($subscription_id);
    public function Cancelar(Suscripciones $Suscripcion, String $Tipo = '');
}
