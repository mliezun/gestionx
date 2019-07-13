<?php

namespace common\models;

use common\components\FechaHelper;
use Yii;

class GestorVentas
{
    /**
     * Permite dar de alta una venta en un punto de venta, indicando el cliente, el tipo de venta y el usuario.
	 * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_venta
     */
    public function Alta(Ventas $venta)
    {
        $sql = "call xsp_alta_venta( :token, :idempresa, :idpuntoventa, :idcliente,
        :idusuario, :tipo, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idusuario' => Yii::$app->user->identity->IdUsuario,
            ':idcliente' => $venta->IdCliente,
            ':idpuntoventa' => $venta->IdPuntoVenta,
            ':tipo' => $venta->Tipo,
            ':observaciones' => $venta->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite modificar una venta en un punto de venta, siempre y cuando la venta este en edicion.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_venta
     */
    public function Modificar(Ventas $venta)
    {
        $sql = "call xsp_modifica_venta( :token, :idventa, :idempresa, :idcliente,
        :idusuario, :tipo, :observaciones, :idusuariogestion , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idusuariogestion' => Yii::$app->user->identity->IdUsuario,
            ':idcliente' => $venta->IdCliente,
            ':idventa' => $venta->$IdVenta,
            ':idusuario' => $venta->$IdUsuario,
            ':tipo' => $venta->Tipo,
            ':observaciones' => $venta->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite borrar una venta controlando que no tenga pagos o lineas ventas asosiadas,
     * siempre y cunado se encuentre en estado de edicion.
	 * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_venta
     */
    public function Borrar(Ventas $venta)
    {
        $sql = "call xsp_borra_venta( :token, :idventa, :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idventa' => $venta->$IdVenta,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar las ventas de un punto de venta, dado el tipo de venta (T para listar todas),
     * el estado (T para listar todos), un cliente (0 para listar todos) y un rango de fechas.
     * Para listar todos, rango de fechas nulo.
     * xsp_buscar_ventas
     */
    public function Buscar($PuntoVenta, $FechaDesde = null, $FechaHasta = null, $Cliente = 0, $Estado = 'E', $Tipo = 'T')
    {
        $sql = "call xsp_buscar_ventas( :idpuntoventa, :idempresa, :fechadesde, :fechahasta, :idcliente, :tipo, :estado)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idcliente' => $Cliente,
            ':fechadesde' => FechaHelper::formatearDateMysql($FechaDesde),
            ':fechahasta' => FechaHelper::formatearDateMysql($FechaHasta),
            ':estado' => $Estado,
            ':tipo' => $Tipo,
            ':idpuntoventa' => $PuntoVenta,
        ]);

        return $query->queryAll();
    }
}
