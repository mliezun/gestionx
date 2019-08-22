<?php

namespace common\models;

use Yii;

class GestorArticulos
{
    /**
     * Permite dar de alta un articulo. Controlando que el nombre y el código del articulo
     * no existan ya dentro del mismo proveedor. Devuelve OK+Id o el mensaje de error en Mensaje.
     * xsp_alta_articulo
     * 
     */
    public function Alta(Articulos $Articulo)
    {
        $sql = "call xsp_alta_articulo( :token, :idprov, :idempresa, :articulo, "
            . ":codigo, :desc, :pcosto, :pventa, :pidstiposgravamene, :idslistaprecio, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => $Articulo->IdEmpresa,
            ':idprov' => $Articulo->IdProveedor,
            ':articulo' => $Articulo->Articulo,
            ':codigo' => $Articulo->Codigo,
            ':desc' => $Articulo->Descripcion,
            ':pcosto' => $Articulo->PrecioCosto,
            ':pventa' => $Articulo->PrecioVenta,
            ':pidstiposgravamene' => json_encode($Articulo->Gravamenes),
            ':idslistaprecio' => json_encode($Articulo->PreciosVenta),
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite buscar articulos dentro de un proveedor de una empresa, indicando una
     * cadena de búsqueda y si se incluyen bajas. Si pIdProveedor = 0 lista para todos
     * los proveedores activos de una empresa.
     * xsp_buscar_articulos
     * 
     */
    public function Buscar($IdProveedor = 0,  $Cadena = '', $IncluyeBajas = 'N')
    {
        $sql = "call xsp_buscar_articulos( :idempresa, :idprov, :cadena, :iBajas , :iBajasListas)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idprov' => $IdProveedor,
            ':cadena' => $Cadena,
            ':iBajas' => $IncluyeBajas,
            ':iBajasListas' => 'S',
        ]);

        $res = $query->queryAll();

        foreach ($res as &$elemento) {
            foreach (json_decode($elemento['PreciosVenta']) as $nombre => $valor){
                if($nombre == 'Por Defecto'){
                    $elemento['PrecioVenta'] = $valor;
                }
            }
        }

        return $res;
    }

    /**
     * Permite buscar articulos y su precios para un cliente de una empresa, indicando una cadena de búsqueda.
     * 
     * xsp_buscar_articulos_por_cliente
     */
    public function BuscarPorCliente($IdCliente = 0,  $Cadena = '')
    {
        $sql = "call xsp_buscar_articulos_por_cliente( :idempresa, :idcliente, :cadena)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idcliente' => $IdCliente,
            ':cadena' => $Cadena,
        ]);

        return $query->queryAll();
    }

    /**
     * Permite cambiar el nombre, el código, la descripción, el precio y el IVA de un articulo,
     * verificando que no exista uno igual dentro del mismo proveedor.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_modifica_articulo
     */
    public function Modificar(Articulos $Articulo)
    {
        $sql = "call xsp_modifica_articulo( :token, :idarticulo, :articulo, "
            . ":codigo, :desc, :pcosto, :pventa, :pidstiposgravamenes, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idarticulo' => $Articulo->IdArticulo,
            ':articulo' => $Articulo->Articulo,
            ':codigo' => $Articulo->Codigo,
            ':desc' => $Articulo->Descripcion,
            ':pcosto' => $Articulo->PrecioCosto,
            ':pventa' => $Articulo->PrecioVenta,
            ':pidstiposgravamenes' => json_encode($Articulo->Gravamenes),
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite borrar un articulo controlando que no tenga lineas asociadas.
     * Devuelve OK o el mensaje de error en Mensaje.
     * xsp_borra_articulo
     * 
     */
    public function Borrar(Articulos $Articulo)
    {
        $sql = "call xsp_borra_articulo( :token, :idarticulo, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idarticulo' => $Articulo->IdArticulo
        ]);

        return $query->queryScalar();
    }
}