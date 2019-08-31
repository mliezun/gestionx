<?php
namespace common\models;

use Yii;
use yii\base\Model;
use common\models\forms\LineasForm;

class Ventas extends Model
{
    public $IdVenta;
    public $IdPuntoVenta;
    public $IdEmpresa;
    public $IdCliente;
    public $IdUsuario;
    public $IdTipoComprobanteAfip;
    public $IdTipoTributo;
    public $Monto;
    public $FechaAlta;
    public $Tipo;
    public $Estado;
    public $Observaciones;

    // Derivados
    public $MontoPagado;
    public $TipoComprobanteAfip;
    public $TipoTributo;
    public $Cliente;
    public $Usuario;
    
    const _ALTA = 'alta';
    const _MODIFICAR = 'modificar';
    
    const ESTADOS = [
        'A' => 'Activo',
        'E' => 'Edicion',
        'B' => 'Baja',
        'T' => 'Todos'
    ];

    const TIPOS_ALTA = [
        'P' => 'Presupuesto',
        'C' => 'Cotización',
        'V' => 'Venta',
        'B' => 'Prestamo'
    ];

    const TIPOS = [
        'P' => 'Presupuesto',
        'C' => 'Cotización',
        'V' => 'Venta',
        'B' => 'Prestamo',
        'T' => 'Todos'
    ];

    public function attributeLabels()
    {
        return [
            'IdCliente' => 'Cliente',
            'IdTipoComprobanteAfip' => 'Tipo de Comprobante',
            'IdTipoTributo' => 'Tipo de Tributo'
        ];
    }
 
    public function rules()
    {
        return [
            [['IdCliente','Tipo','IdTipoTributo','IdTipoComprobanteAfip'],
                'required', 'on' => self::_ALTA],
            [['IdVenta','IdCliente','Tipo','IdTipoTributo','IdTipoComprobanteAfip'],
                'required', 'on' => self::_MODIFICAR],
            [$this->attributes(), 'safe']
        ];
    }

    /**
     * Permite instanciar una venta desde la base de datos.
     * xsp_dame_venta
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_venta( :idventa )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idventa' => $this->IdVenta
        ]);
        
        $this->attributes = $query->queryOne();
    }


    /**
     * Permite cambiar el estado de la Venta siempre y cuando no esté dado de baja ya.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_venta
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_venta( :token, :idventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado de la Venta a Activo siempre y cuando el estado actual sea Edicion.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_venta
     */
    public function Activar()
    {
        $sql = "call xsp_activar_venta( :token, :idventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite agregar una línea a una venta que se encuentre en estado En edición.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_alta_linea_venta
     */
    public function AgregarLinea(LineasForm $linea)
    {
        $sql = "call xsp_alta_linea_venta( :token, :idVenta, :idart, :cant, :precio, :consumestock, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idVenta' => $this->IdVenta,
            ':idart' => $linea->IdArticulo,
            ':cant' => $linea->Cantidad,
            ':precio' => $linea->Precio,
            ':consumestock' => ($this->Tipo == 'P') ? 'N' : 'S'
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite quitar una línea a una venta que se encuentre en estado En edición.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borrar_linea_venta
     */
    public function QuitarLinea($IdArticulo)
    {
        $sql = "call xsp_borrar_linea_venta( :token, :idVenta, :idart, :consumestock, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idVenta' => $this->IdVenta,
            ':idart' => $IdArticulo,
            ':consumestock' => ($this->Tipo == 'P') ? 'N' : 'S'
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite obtener las líneas de una venta.
     * xsp_dame_lineas_venta
     */
    public function DameLineas()
    {
        $sql = "call xsp_dame_lineas_venta( :idVenta )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idVenta' => $this->IdVenta
        ]);

        return $query->queryAll();
    }

    /**
     * Permite cambiar el estado de la Venta a baja y agregar existencias articulos vendidos.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_devolucion_venta
     */
    public function Devolucion()
    {
        $sql = "call xsp_devolucion_venta( :token, :idventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta
        ]);

        return $query->queryScalar();
    }

    /**
     * 
     * xsp_pagar_venta_efectivo
     */
    public function PagarEfectivo(Pagos $pago)
    {
        $sql = "call xsp_pagar_venta_efectivo( :token, :idventa, :idmediopago, :monto, 
        :fechadebe, :fechapago, :observaciones, :IdTipoComprobante , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta,
            ':idmediopago' => $pago->IdMedioPago,
            ':monto' => $pago->Monto,
            ':fechadebe' => $pago->FechaDebe,
            ':fechapago' => $pago->FechaPago,
            ':IdTipoComprobante' => $pago->IdTipoComprobante,
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * 
     * xsp_pagar_venta_tarjeta
     */
    public function PagarTarjeta(Pagos $pago)
    {
        $sql = "call xsp_pagar_venta_tarjeta( :token, :idventa, :idmediopago, :monto, 
        :fechadebe, :fechapago, :observaciones, :IdTipoComprobante,
        :NroTarjeta, :MesVencimiento, :AnioVencimiento, :CCV , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta,
            ':idmediopago' => $pago->IdMedioPago,
            ':monto' => $pago->Monto,
            ':fechadebe' => $pago->FechaDebe,
            ':fechapago' => $pago->FechaPago,
            ':IdTipoComprobante' => $pago->IdTipoComprobante,
            ':observaciones' => $pago->Observaciones,
            ':NroTarjeta' => $pago->NroTarjeta,
            ':MesVencimiento' => $pago->MesVencimiento,
            ':AnioVencimiento' => $pago->AnioVencimiento,
            ':CCV' => $pago->CCV,
        ]);

        return $query->queryScalar();
    }

    /**
     * 
     * xsp_pagar_venta_cheque
     */
    public function PagarCheque(Pagos $pago)
    {
        $sql = "call xsp_pagar_venta_cheque( :token, :idventa, :idmediopago, 
        :fechadebe, :fechapago, :IdCheque, :observaciones, :IdTipoComprobante,
        :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta,
            ':idmediopago' => $pago->IdMedioPago,
            ':IdCheque' => $pago->IdCheque,
            ':fechadebe' => $pago->FechaDebe,
            ':fechapago' => $pago->FechaPago,
            ':IdTipoComprobante' => $pago->IdTipoComprobante,
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * 
     * xsp_pagar_venta_mercaderia
     */
    public function PagarMercaderia(Pagos $pago)
    {
        $sql = "call xsp_pagar_venta_mercaderia( :token, :idventa, :idmediopago,
        :fechadebe, :fechapago, :IdRemito, :observaciones, :IdTipoComprobante,
        :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $this->IdVenta,
            ':idmediopago' => $pago->IdMedioPago,
            ':IdRemito' => $pago->IdRemito,
            ':fechadebe' => $pago->FechaDebe,
            ':fechapago' => $pago->FechaPago,
            ':IdTipoComprobante' => $pago->IdTipoComprobante,
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * 
     * xsp_pagar_venta_efectivo
     */
    public function ModificarPagoEfectivo(Pagos $pago)
    {
        $sql = "call xsp_modificar_pago_efectivo( :token, :idpago, :monto, 
        :fechadebe, :fechapago, :observaciones, :IdTipoComprobante , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
            ':monto' => $pago->Monto,
            ':fechadebe' => $pago->FechaDebe,
            ':fechapago' => $pago->FechaPago,
            ':IdTipoComprobante' => $pago->IdTipoComprobante,
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * 
     * xsp_pagar_venta_tarjeta
     */
    public function ModificarPagoTarjeta(Pagos $pago)
    {
        $sql = "call xsp_modificar_pago_tarjeta( :token, :idpago, :monto, 
        :fechadebe, :fechapago, :observaciones, :IdTipoComprobante,
        :NroTarjeta, :MesVencimiento, :AnioVencimiento, :CCV , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
            ':monto' => $pago->Monto,
            ':fechadebe' => $pago->FechaDebe,
            ':fechapago' => $pago->FechaPago,
            ':IdTipoComprobante' => $pago->IdTipoComprobante,
            ':observaciones' => $pago->Observaciones,
            ':NroTarjeta' => $pago->NroTarjeta,
            ':MesVencimiento' => $pago->MesVencimiento,
            ':AnioVencimiento' => $pago->AnioVencimiento,
            ':CCV' => $pago->CCV,
        ]);

        return $query->queryScalar();
    }

    /**
     * 
     * xsp_pagar_venta_cheque
     */
    public function ModificarPagoCheque(Pagos $pago)
    {
        $sql = "call xsp_modificar_pago_cheque( :token, :idpago, 
        :fechadebe, :fechapago, :IdCheque, :observaciones, :IdTipoComprobante,
        :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
            ':IdCheque' => $pago->IdCheque,
            ':fechadebe' => $pago->FechaDebe,
            ':fechapago' => $pago->FechaPago,
            ':IdTipoComprobante' => $pago->IdTipoComprobante,
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * 
     * xsp_pagar_venta_mercaderia
     */
    public function ModificarPagoMercaderia(Pagos $pago)
    {
        $sql = "call xsp_modificar_pago_mercaderia( :token, :idpago,
        :fechadebe, :fechapago, :IdRemito, :observaciones, :IdTipoComprobante,
        :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
            ':IdRemito' => $pago->IdRemito,
            ':fechadebe' => $pago->FechaDebe,
            ':fechapago' => $pago->FechaPago,
            ':IdTipoComprobante' => $pago->IdTipoComprobante,
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }
    
    /**
     * Permite obtener los pagos de una venta.
     * xsp_dame_pagos_venta
     */
    public function DamePagos()
    {
        $sql = "call xsp_dame_pagos_venta( :idVenta )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idVenta' => $this->IdVenta
        ]);

        return $query->queryAll();
    }

    public function BorrarPago(Pagos $pago)
    {
        $sql = "call xsp_borrar_pago_venta( :token, :idpago, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
        ]);

        return $query->queryScalar();
    }
}