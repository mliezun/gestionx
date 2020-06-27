<?php

namespace common\models;

use Yii;

class GestorPuntosVenta
{
    /**
     * Permite dar de alta un Punto Venta controlando que el nombre del Punto Venta no exista ya dentro de la misma empresa.
     * Devuelve OK + Id o el mensaje de error en Mensaje.
     * xsp_alta_puntoventa
     */
    public function Alta($puntoventa)
    {
        $sql = "call xsp_alta_puntoventa( :token, :host, :puntoventa, :datos, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':host' => Yii::$app->request->headers->get('host'),
            ':puntoventa' => $puntoventa->PuntoVenta,
            ':datos' => json_encode([
                'Telefono' => $puntoventa->Telefono,
                'Direccion' => $puntoventa->Direccion,
                'NroPuntoVenta' => $puntoventa->NroPuntoVenta
            ]),
            ':observaciones' => $puntoventa->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar los puntos venta dada una cadena de búsqueda y estado (T: todos los estados).
     * Para listar todos, cadena vacía.
     * xsp_buscar_puntosventa
     */
    public function Buscar($Cadena = '', $Estado = 'A')
    {
        $sql = "call xsp_buscar_puntosventa( :host, :cadena, :estado )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':host' => Yii::$app->request->headers->get('host'),
            ':cadena' => $Cadena,
            ':estado' => $Estado,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite modificar un PuntoVenta existente controlando que el nombre del puntoventa no exista ya.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_puntoventa
     */
    public function Modificar($puntoventa)
    {
        $sql = "call xsp_modifica_puntoventa( :token, :host, :idpuntoventa, :puntoventa, :datos, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':host' => Yii::$app->request->headers->get('host'),
            ':idpuntoventa' => $puntoventa->IdPuntoVenta,
            ':puntoventa' => $puntoventa->PuntoVenta,
            ':datos' => json_encode([
                'Telefono' => $puntoventa->Telefono,
                'Direccion' => $puntoventa->Direccion,
                'NroPuntoVenta' => $puntoventa->NroPuntoVenta
            ]),
            ':observaciones' => $puntoventa->Observaciones,
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite borrar un PuntoVenta existente controlando que no existan ventas, rectificaciones pv,
     * ingresos o existencias cosolidadas asociadas.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_puntoventa
     */
    public function Borrar($puntoventa)
    {
        $sql = "call xsp_borra_puntoventa( :token, :idpuntoventa, :observaciones , :IP, :userAgent, :app)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idpuntoventa' => $puntoventa->IdPuntoVenta,
            ':observaciones' => $puntoventa->Observaciones,
        ]);

        return $query->queryScalar();
    }
}
