<?php

namespace common\models;

interface IOperacionesPago
{
    // Alta
    public function PagarEfectivo(Pagos $pago);
    public function PagarTarjeta(Pagos $pago);
    public function PagarCheque(Pagos $pago);
    public function PagarMercaderia(Pagos $pago);
    public function PagarRetencion(Pagos $pago);
    // Modifica
    public function ModificarPagoEfectivo(Pagos $pago);
    public function ModificarPagoTarjeta(Pagos $pago);
    public function ModificarPagoCheque(Pagos $pago);
    public function ModificarPagoMercaderia(Pagos $pago);
    public function ModificarPagoRetencion(Pagos $pago);
    // Borra
    public function BorrarPago(Pagos $pago);
}
