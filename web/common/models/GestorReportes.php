<?php

namespace common\models;

use common\models\InformesHelper;
use yii\base\Model;
use Yii;

/**
 * @version 1.0
 * @created 16-Dec-2015 18:19:38
 */
class GestorReportes extends Model
{

    /**
     * Lista el menú correspondiente a los informes, adjuntando un campo que dice si
     * es o no es hoja (EsHoja = [S|N], cuando no es hoja es un menú de distribución).
     * si es o no permiso hoja (EsHoja = [S|N]). Los ítems de menú están listados en
     * orden jerárquico y arbóreo, con el nodo padre, el nivel del árbol y una cadena
     * para mostrarlo ordenado. xsp_inf_listar_menu_reportes
     */
    public function ListarMenu()
    {
        $sql = "CALL xsp_inf_listar_menu_reportes (:idEmpresa)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':idEmpresa' => Yii::$app->user->identity->IdEmpresa,
        ]);


        return $query->queryAll();
    }

    /**
     * Trae todos los campos de la tabla ModelosReporte. xsp_inf_dame_modeloreporte.
     *
     * @param IdModeloReporte
     */
    public function DameModeloReporte($IdModeloReporte)
    {
        $sql = "CALL xsp_inf_dame_modeloreporte ( :idEmpresa, :id )";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':idEmpresa' => Yii::$app->user->identity->IdEmpresa,
            ':id' => $IdModeloReporte,
        ]);

        return $query->queryOne();
    }

    /**
     * Trae todos los parámetros de un modelo de reporte ordenados por pTipoOrden: P:
     * Parámetro - F: Formulario. xsp_inf_dame_parametros_modeloreporte
     *
     * @param IdModeloReporte
     * @param TipoOrden    P: Parámetro - F: Formulario
     */
    public function DameParametrosModeloReporte($IdModeloReporte, $TipoOrden = 'F')
    {
        $sql = "CALL xsp_inf_dame_parametros_modeloreporte ( :idEmpresa, :id, :tipo)";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':idEmpresa' => Yii::$app->user->identity->IdEmpresa,
            ':id' => $IdModeloReporte,
            ':tipo' => $TipoOrden
        ]);

        return $query->queryAll();
    }

    /**
     * Permite traer un resultset de forma {Id,Nombre} para poblar la lista del
     * parámetro que debe ser de tipo L: Listado. Lo ordena por nombre. No incluye el
     * TODOS. xsp_inf_llenar_listado_parametro
     *
     * @param IdModeloReporte
     * @param NroParametro
     * @param Cadena    vacía para cuando el tipo es L, con el valor de autocompletar
     * cuando el tipo es A
     */
    public function LlenarListadoParametro($IdModeloReporte, $NroParametro, $Cadena = '')
    {
        $sql = "CALL xsp_inf_llenar_listado_parametro ( :idEmpresa, :id, :nroParam, :cadena )";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':idEmpresa' => Yii::$app->user->identity->IdEmpresa,
            ':id' => $IdModeloReporte,
            ':nroParam' => $NroParametro,
            ':cadena' => $Cadena
        ]);

        return $query->queryAll();
    }

    /**
     * Permite traer un resultset de forma {Id,Nombre} para poblar la lista del
     * parámetro que debe ser de tipo L: Listado. Lo ordena por nombre. No incluye el
     * TODOS. xsp_inf_dame_parametro_listado
     *
     * @param IdModeloReporte
     * @param NroParametro
     * @param Id    Id que puede ser una cadena o número entero
     */
    public function DameParametroListado($IdModeloReporte, $NroParametro, $Id = '')
    {
        $sql = "CALL xsp_inf_dame_parametro_listado ( :idEmpresa, :idReporte, :nroParam, :id )";

        $query = Yii::$app->db->createCommand($sql);

        $query->bindValues([
            ':idEmpresa' => Yii::$app->user->identity->IdEmpresa,
            ':idReporte' => $IdModeloReporte,
            ':nroParam' => $NroParametro,
            ':id' => $Id
        ]);

        return $query->queryOne();
    }

    /**
     * Esta función se usa para el Sistema de Auditoría
     *
     * Permite traer el resultset del reporte. Para ello trae el nombre del SP de la
     * tabla ModelosReporte. xsp_inf_ejecutar_reporte
     *
     * @param IdModeloReporte
     * @param CadenaParam    Cadena formada por lo que va dentro de los paréntesis en
     * un llamado a SP. De acuerdo al tipo van o no las comillas. El orden es el de
     * NroParametro.
     */
    public function Ejecutar($IdEmpresa, $IdModeloReporte, $CadenaParam)
    {
        $sql = "CALL xsp_inf_ejecutar_reporte ( :idEmpresa, :id, :cadena )";

        $query = Yii::$app->db->createCommand($sql);
        
        $query->bindValues([
            ':idEmpresa' => $IdEmpresa,
            ':id' => $IdModeloReporte,
            ':cadena' => $CadenaParam
        ]);

        $resultado = InformesHelper::expand($query->queryAll());

        return $resultado;
    }
}
