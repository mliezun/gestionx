<?php
namespace common\models;

use common\helpers\FechaHelper;
use Yii;
use yii\base\Model;

class Clientes extends Model implements IOperacionesPago
{
    public $IdCliente;
    public $IdEmpresa;
    public $Nombres;
    public $Apellidos;
    public $RazonSocial;
    public $Datos;
    public $FechaAlta;
    public $Tipo;
    public $Estado;
    public $Observaciones;
    public $IdListaPrecio;
    public $IdTipoDocAfip;

    //Derivados
    public $Lista;
    public $TipoDocAfip;
    public $Deuda;

    // DatosJSON
    public $CUIT;
    public $CUIL;
    public $Pasaporte;
    public $DNI;
    public $Telefono;
    public $Provincia;
    public $Localidad;
    public $Direccion;
    public $Documento;
    public $Email;
    
    const _ALTA_FISICA = 'altaf';
    const _ALTA_JURIDICA = 'altaj';
    const _MODIFICAR_FISICA = 'modificarf';
    const _MODIFICAR_JURIDICA = 'modificarj';
    const _ALTA_EMAIL = 'altae';
    
    const ESTADOS = [
        'A' => 'Activo',
        'B' => 'Baja',
        'T' => 'Todos'
    ];

    const TIPOS = [
        'F' => 'Fisica',
        'J' => 'Juridica',
        'T' => 'Todos'
    ];
 
    public function rules()
    {
        return [
            ['Documento', 'trim'],
            ['Email', 'email'],
            ['Provincia', 'in', 'range' => Provincias::Nombres()],
            [['Nombres', 'Apellidos', 'Tipo', 'IdListaPrecio', 'IdTipoDocAfip', 'Documento'],
                'required', 'on' => self::_ALTA_FISICA],
            [['RazonSocial','Tipo', 'IdListaPrecio', 'IdTipoDocAfip', 'Documento'],
                'required', 'on' => self::_ALTA_JURIDICA],
            [['IdCliente','IdEmpresa','Nombres', 'Apellidos', 'IdListaPrecio', 'IdTipoDocAfip'],
                'required', 'on' => self::_MODIFICAR_FISICA],
            [['IdCliente','IdEmpresa','RazonSocial', 'IdListaPrecio', 'IdTipoDocAfip'],
                'required', 'on' => self::_MODIFICAR_JURIDICA],
            [['IdCliente', 'Email'],
                'required', 'on' => self::_ALTA_EMAIL],
            [$this->attributes(), 'safe']
        ];
    }

    public function attributeLabels()
    {
        return [
            'IdListaPrecio' => 'Lista',
            'IdTipoDocAfip' => 'Tipo de Documento'
        ];
    }

    public static function Nombre($cliente)
    {
        $nombre = '';
        if ($cliente['Tipo'] == 'F') {
            $nombre = $cliente['Apellidos'] . ', ' . $cliente['Nombres'];
        } else {
            $nombre = $cliente['RazonSocial'];
        }
        return $nombre;
    }

    public function getNombre()
    {
        return self::Nombre($this->getAttributes());
    }

    /**
     * Permite instanciar un cliente desde la base de datos.
     * xsp_dame_cliente
     */
    public function Dame()
    {
        $sql = 'CALL xsp_dame_cliente( :idcliente )';
        
        $query = Yii::$app->db->createCommand($sql);
    
        $query->bindValues([
            ':idcliente' => $this->IdCliente
        ]);
        
        $this->attributes = $query->queryOne();

        foreach (json_decode($this['Datos'], true) as $dato => $valor) {
            if (isset($valor) && $valor != '') {
                $this->$dato = $valor;
            }
        }
    }


    /**
     * Permite dar de baja a un Cliente siempre y cuando no esté dado de baja ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_darbaja_cliente
     */
    public function DarBaja()
    {
        $sql = "call xsp_darbaja_cliente( :token, :idcliente, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcliente' => $this->IdCliente
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite cambiar el estado del Cliente a Activo siempre y cuando no esté activo ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_activar_cliente
     */
    public function Activar()
    {
        $sql = "call xsp_activar_cliente( :token, :idcliente, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcliente' => $this->IdCliente
        ]);

        return $query->queryScalar();
    }

    /*
    * Permite listar el historial de descuentos de un cliente.
    *
    * xsp_listar_historial_cuenta_cliente
    */
    public function ListarHistorialCuenta($FechaInicio = null, $FechaFin = null)
    {
        $sql = 'CALL xsp_listar_historial_cuenta_cliente( :id, :fechainicio, :fechafin)';
        
        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':id' => $this->IdCliente,
            ':fechainicio' => FechaHelper::formatearDateMysql($FechaInicio),
            ':fechafin' => FechaHelper::formatearDateMysql($FechaFin),
        ]);
        
        return $query->queryAll();
    }

    /**
     * Permite buscar los pagos de un cliente, entre 2 fechas.
     * Permitiendo filtrar por medio de pago (0 para listar todos).
     * 
     * xsp_buscar_pagos_cliente
     */
    public function BuscarPagos($FechaInicio = null, $FechaFin = null, $IdMedioPago = 0)
    {
        $sql = "call xsp_buscar_pagos_cliente( :id, :IdMedioPago, :fechainicio, :fechafin)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':id' => $this->IdCliente,
            ':IdMedioPago' => $IdMedioPago,
            ':fechainicio' => FechaHelper::formatearDateMysql($FechaInicio),
            ':fechafin' => FechaHelper::formatearDateMysql($FechaFin),
        ]);

        return $query->queryAll();
    }

    // Alta de Pagos
    public function PagarEfectivo(Pagos $pago)
    {
        $sql = "call xsp_pagar_cliente_efectivo( :token, :idCliente, :idmediopago, :monto, 
        :fechadebe, :fechapago, :observaciones, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idCliente' => $this->IdCliente,
            ':idmediopago' => $pago->IdMedioPago,
            ':monto' => $pago->Monto,
            ':fechadebe' => FechaHelper::formatearDateMysql($pago->FechaDebe),
            ':fechapago' => FechaHelper::formatearDateMysql($pago->FechaPago),
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    public function PagarTarjeta(Pagos $pago)
    {
        $sql = "call xsp_pagar_cliente_tarjeta( :token, :id, :idmediopago, :monto, "
        .":fechadebe, :fechapago, :observaciones,"
        .":NroTarjeta, :MesVencimiento, :AnioVencimiento, :CCV , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':id' => $this->IdCliente,
            ':idmediopago' => $pago->IdMedioPago,
            ':monto' => $pago->Monto,
            ':fechadebe' => FechaHelper::formatearDateMysql($pago->FechaDebe),
            ':fechapago' => FechaHelper::formatearDateMysql($pago->FechaPago),
            ':observaciones' => $pago->Observaciones,
            ':NroTarjeta' => $pago->NroTarjeta,
            ':MesVencimiento' => $pago->MesVencimiento,
            ':AnioVencimiento' => $pago->AnioVencimiento,
            ':CCV' => $pago->CCV,
        ]);

        return $query->queryScalar();
    }

    public function PagarCheque(Pagos $pago)
    {
        $sql = "call xsp_pagar_cliente_cheque( :token, :idCliente, :idmediopago, "
        .":fechadebe, :fechapago, :IdCheque, :observaciones,"
        .":IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idCliente' => $this->IdCliente,
            ':idmediopago' => $pago->IdMedioPago,
            ':IdCheque' => $pago->IdCheque,
            ':fechadebe' => FechaHelper::formatearDateMysql($pago->FechaDebe),
            ':fechapago' => FechaHelper::formatearDateMysql($pago->FechaPago),
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    public function PagarMercaderia(Pagos $pago)
    {
        return "Medio de Pago no soportado";
    }

    public function PagarRetencion(Pagos $pago)
    {
        $sql = "call xsp_pagar_cliente_retencion( :token, :idCliente, :idmediopago, :idtipotributo, :monto, 
        :fechadebe, :fechapago, :observaciones, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idCliente' => $this->IdCliente,
            ':idmediopago' => $pago->IdMedioPago,
            ':idtipotributo' => $pago->IdTipoTributo,
            ':monto' => $pago->Monto,
            ':fechadebe' => FechaHelper::formatearDateMysql($pago->FechaDebe),
            ':fechapago' => FechaHelper::formatearDateMysql($pago->FechaPago),
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    // Modificacion de Pagos
    public function ModificarPagoEfectivo(Pagos $pago)
    {
        $sql = "call xsp_modificar_pago_cliente_efectivo( :token, :idpago, :monto, "
        .":fechadebe, :fechapago, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
            ':monto' => $pago->Monto,
            ':fechadebe' => FechaHelper::formatearDateMysql($pago->FechaDebe),
            ':fechapago' => FechaHelper::formatearDateMysql($pago->FechaPago),
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    public function ModificarPagoTarjeta(Pagos $pago)
    {
        $sql = "call xsp_modificar_pago_cliente_tarjeta( :token, :idpago, :monto, "
        .":fechadebe, :fechapago, :observaciones, :NroTarjeta, :MesVencimiento, :AnioVencimiento, :CCV , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
            ':monto' => $pago->Monto,
            ':fechadebe' => FechaHelper::formatearDateMysql($pago->FechaDebe),
            ':fechapago' => FechaHelper::formatearDateMysql($pago->FechaPago),
            ':observaciones' => $pago->Observaciones,
            ':NroTarjeta' => $pago->NroTarjeta,
            ':MesVencimiento' => $pago->MesVencimiento,
            ':AnioVencimiento' => $pago->AnioVencimiento,
            ':CCV' => $pago->CCV,
        ]);

        return $query->queryScalar();
    }

    public function ModificarPagoCheque(Pagos $pago)
    {
        $sql = "call xsp_modificar_pago_cliente_cheque( :token, :idpago, "
        .":fechadebe, :fechapago, :IdCheque, :observaciones, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
            ':IdCheque' => $pago->IdCheque,
            ':fechadebe' => FechaHelper::formatearDateMysql($pago->FechaDebe),
            ':fechapago' => FechaHelper::formatearDateMysql($pago->FechaPago),
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    public function ModificarPagoMercaderia(Pagos $pago)
    {
        return "Medio de Pago no soportado";
    }

    public function ModificarPagoRetencion(Pagos $pago)
    {
        $sql = "call xsp_modificar_pago_cliente_retencion( :token, :idpago, :idtipotributo, :monto, "
        .":fechadebe, :fechapago, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpago' => $pago->IdPago,
            ':idtipotributo' => $pago->IdTipoTributo,
            ':monto' => $pago->Monto,
            ':fechadebe' => FechaHelper::formatearDateMysql($pago->FechaDebe),
            ':fechapago' => FechaHelper::formatearDateMysql($pago->FechaPago),
            ':observaciones' => $pago->Observaciones,
        ]);

        return $query->queryScalar();
    }

    public function BorrarPago(Pagos $pago)
    {
        $sql = "call xsp_borrar_pago_cliente( :token, :idpago, :IP, :userAgent, :app)";

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
