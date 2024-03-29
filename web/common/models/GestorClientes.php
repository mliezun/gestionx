<?php

namespace common\models;

use common\helpers\FechaHelper;
use Yii;

class GestorClientes
{
    /**
     * Permite dar de alta un Cliente.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_cliente
     */
    public function Alta(Clientes $cliente)
    {
        $sql = "call xsp_alta_cliente( :token, :idempresa, :idlista, :iddoc, :nombres, :apellidos,"
        .":razonsocial, :documento, :datos, :tipo, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idlista' => $cliente->IdListaPrecio,
            ':iddoc' => $cliente->IdTipoDocAfip,
            ':nombres' => $cliente->Nombres,
            ':apellidos' => $cliente->Apellidos,
            ':razonsocial' => $cliente->RazonSocial,
            ':documento' => $cliente->Documento,
            ':datos' => json_encode([
                'Email' => $cliente->Email,
                'Telefono' => $cliente->Telefono,
                'Provincia' => $cliente->Provincia,
                'Localidad' => $cliente->Localidad,
                'Direccion' => $cliente->Direccion,
                'CUIT' => $cliente->CUIT,
                'DNI' => $cliente->DNI,
                'Pasaporte' => $cliente->Pasaporte,
                'CUIL' => $cliente->CUIL,
            ]),
            ':tipo' => $cliente->Tipo,
            ':observaciones' => $cliente->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar un Cliente.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_cliente
     */
    public function Modificar(Clientes $cliente)
    {
        $sql = "call xsp_modifica_cliente( :token, :idcliente, :idempresa, :idlista, :iddoc, "
        .":nombres, :apellidos, :razonsocial, :documento, :datos, :tipo, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcliente' => $cliente->IdCliente,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idlista' => $cliente->IdListaPrecio,
            ':iddoc' => $cliente->IdTipoDocAfip,
            ':nombres' => $cliente->Nombres,
            ':apellidos' => $cliente->Apellidos,
            ':razonsocial' => $cliente->RazonSocial,
            ':documento' => $cliente->Documento,
            ':datos' => json_encode([
                'Email' => $cliente->Email,
                'Telefono' => $cliente->Telefono,
                'Provincia' => $cliente->Provincia,
                'Localidad' => $cliente->Localidad,
                'Direccion' => $cliente->Direccion,
                'CUIT' => $cliente->CUIT,
                'DNI' => $cliente->DNI,
                'Pasaporte' => $cliente->Pasaporte,
                'CUIL' => $cliente->CUIL,
            ]),
            ':tipo' => $cliente->Tipo,
            ':observaciones' => $cliente->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar los clientes dada una cadena de búsqueda, el tipo de cliente (T para listar todas)
     * y la opción si incluye o no los dados de baja [S|N] respectivamente.
     * Para listar todos, cadena vacía.
     * xsp_buscar_clientes
     *
     */
    public function Buscar($Cadena = '', $Tipo = 'T', $Estado = 'A')
    {
        $sql = "call xsp_buscar_clientes( :idempresa, :cadena, :tipo, :estado )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena,
            ':tipo' => $Tipo,
            ':estado' => $Estado,
        ]);

        return $query->queryAll();
    }

    /*
     * Permite buscar entre todos los movimientos de un cliente, entre 2 fechas, permitiendo filtrar los
     * clientes por su estado con pEstado y filtrar las ventas por su estado con pEstadoVenta.
     * Permitiendo ver cuáles están en mora con pMora [S|N].
     * xsp_buscar_ventas_clientes
     *
     */
    public function BuscarVentas($IdCliente = 0, $FechaInicio = null, $FechaFin = null, $Estado = 'T', $EstadoVenta = 'T', $Mora = 'N')
    {
        $sql = "call xsp_buscar_ventas_clientes( :idempresa, :idcliente, :fechaInicio, :fechaFin, :estado, :estadoVenta, :mora )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idcliente' => $IdCliente,
            ':fechaInicio' => FechaHelper::formatearDateMysql($FechaInicio),
            ':fechaFin' => FechaHelper::formatearDateMysql($FechaFin),
            ':estado' => $Estado,
            ':estadoVenta' => $EstadoVenta,
            ':mora' => $Mora
        ]);

        return $query->queryAll();
    }

    /**
     * Permite borrar un cliente controlando que no tenga ventas asosiadas.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_cliente
     */
    public function Borrar(Clientes $cliente)
    {
        $sql = "call xsp_borra_cliente( :token, :idcliente, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idcliente' => $cliente->IdCliente,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite obtener un array del clientes donde la clave es IdCliente y el valor el Nombre
     * del cliente.
     */
    public function Listar()
    {
        $clientes = array();

        foreach ($this->Buscar() as $cliente) {
            $clientes[$cliente['IdCliente']] = Clientes::Nombre($cliente);
        }

        return $clientes;
    }
}
