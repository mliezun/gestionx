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
            . ":codigo, :desc, :pcosto, :idiva, :IP, :userAgent, :app )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':token' => Yii::$app->user->identity->Token,
            ':IP' => Yii::$app->request->userIP,
            ':userAgent' => Yii::$app->request->userAgent,
            ':app' => Yii::$app->id,
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idprov' => $Articulo->IdProveedor,
            ':articulo' => $Articulo->Articulo,
            ':codigo' => $Articulo->Codigo,
            ':desc' => $Articulo->Descripcion,
            ':pcosto' => $Articulo->PrecioCosto,
            ':idiva' => $Articulo->IdTipoIVA
        ]);

        return $query->queryScalar();
    }

    /**
     * Permite obtener la cantidad de artículos de una empresa.
     * xsp_dame_cantidad_articulos
     */
    public function DameCantidad()
    {
        $sql = "call xsp_dame_cantidad_articulos( :idempresa )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa
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
    public function Buscar($Offset = 0, $Limit = 25, $Cadena = '', $IdProveedor = 0, $IdListaPrecio = 0, $IncluyeBajas = 'N', $IncluyeBajasLista = 'N')
    {
        $sql = "call xsp_buscar_articulos( :idempresa, :offset, :limit, :idprov, :idlistaprecio, :cadena, :iBajas , :iBajasListas)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':idprov' => $IdProveedor,
            ':idlistaprecio' => $IdListaPrecio,
            ':cadena' => $Cadena,
            ':iBajas' => $IncluyeBajas,
            ':iBajasListas' => $IncluyeBajasLista,
            ':offset' => $Offset,
            ':limit' => $Limit
        ]);

        return $query->queryAll();
    }

    /**
     * Permite buscar articulos y su precios para un cliente de una empresa, indicando una cadena de búsqueda.
     *
     * xsp_buscar_articulos_por_cliente
     */
    public function BuscarPorCliente($IdCliente = 0, $Cadena = '')
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
     * Permite buscar articulos dentro de una empresa, indicando una
     * cadena de búsqueda.
     * xsp_buscar_articulos_autocompletado
     *
     */
    public function BuscarAutocompletado($Cadena)
    {
        $sql = "call xsp_buscar_articulos_autocompletado( :idempresa, :cadena)";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idempresa' => Yii::$app->user->identity->IdEmpresa,
            ':cadena' => $Cadena
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
            . ":codigo, :desc, :pcosto, :iva, :IP, :userAgent, :app )";

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
            ':iva' => $Articulo->IdTipoIVA,
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
