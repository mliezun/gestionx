<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\Provincias;
use common\models\Clientes;
use common\models\GestorClientes;
use common\models\GestorListasPrecio;
use common\models\GestorTiposDocAfip;
use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use common\components\FechaHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class ClientesController extends Controller
{
    public function actionIndex()
    {
        PermisosHelper::verificarPermiso('BuscarClientes');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorClientes();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $tipo = $busqueda->Combo ? $busqueda->Combo : 'T';
            $estado = $busqueda->Combo2 ? $busqueda->Combo2 : 'A';
            $clientes = $gestor->Buscar($busqueda->Cadena, $tipo, $estado);
        } else {
            $clientes = $gestor->Buscar();
        }

        $paginado->totalCount = count($clientes);
        $clientes = array_slice($clientes, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $clientes,
            'busqueda' => $busqueda,
            'paginado' => $paginado
        ]);
    }

    public function actionAlta()
    {
        PermisosHelper::verificarPermiso('AltaCliente');

        $cliente = new Clientes();

        $cliente->Tipo = Yii::$app->request->get('Tipo');

        if ($cliente->Tipo == 'F') {
            $cliente->setScenario(Clientes::_ALTA_FISICA);
        } else {
            $cliente->setScenario(Clientes::_ALTA_JURIDICA);
        }

        if ($cliente->load(Yii::$app->request->post()) && $cliente->validate()) {
            $gestor = new GestorClientes();
            $resultado = $gestor->Alta($cliente);

            Yii::$app->response->format = 'json';
            if (substr($resultado, 0, 2) == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $listas = GestorListasPrecio::Buscar('S');
            $tiposdoc = GestorTiposDocAfip::Buscar();

            if ($cliente->Tipo == 'F') {
                // Para físicas -> DNI por defecto
                $cliente->IdTipoDocAfip = 96;
            } else {
                // Para jurídicas -> CUIT por defecto
                $cliente->IdTipoDocAfip = 80;
            }

            $cliente->Provincia = Provincias::Dame(Yii::$app->session->get('Parametros')['PROVINCIA']);

            return $this->renderAjax('alta', [
                'titulo' => 'Alta Cliente',
                'model' => $cliente,
                'listas' => $listas,
                'tiposdoc' => $tiposdoc
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarCliente');
        
        $cliente = new Clientes();
        $cliente->IdCliente = $id;
        $cliente->Dame();

        // $clienteAux = new Clientes();
        // $clienteAux->IdCliente = $id;
        // $clienteAux->Dame();
        if ($cliente->Tipo == 'F') {
            $cliente->setScenario(Clientes::_MODIFICAR_FISICA);
        } else {
            $cliente->setScenario(Clientes::_MODIFICAR_JURIDICA);
        }
        
        if ($cliente->load(Yii::$app->request->post()) && $cliente->validate()) {
            $gestor = new GestorClientes();
            $resultado = $gestor->Modificar($cliente);

            Yii::$app->response->format = 'json';
            if ($resultado == 'OK') {
                return ['error' => null];
            } else {
                return ['error' => $resultado];
            }
        } else {
            $listas = GestorListasPrecio::Buscar('S');
            $tiposdoc = GestorTiposDocAfip::Buscar();

            return $this->renderAjax('alta', [
                        'titulo' => 'Editar Cliente',
                        'model' => $cliente,
                        'listas' => $listas,
                        'tiposdoc' => $tiposdoc
            ]);
        }
    }

    public function actionBorrar($id)
    {
        PermisosHelper::verificarPermiso('BorrarCliente');

        Yii::$app->response->format = 'json';
        
        $cliente = new Clientes();
        $cliente->IdCliente = $id;

        $gestor = new GestorClientes();

        $resultado = $gestor->Borrar($cliente);

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionActivar($id)
    {
        PermisosHelper::verificarPermiso('ActivarCliente');

        Yii::$app->response->format = 'json';
        
        $cliente = new Clientes();
        $cliente->IdCliente = $id;

        $resultado = $cliente->Activar();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionDarBaja($id)
    {
        PermisosHelper::verificarPermiso('DarBajaCliente');

        Yii::$app->response->format = 'json';
        
        $cliente = new Clientes();
        $cliente->IdCliente = $id;

        $resultado = $cliente->DarBaja();

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    public function actionVentas($id = 0)
    {
        PermisosHelper::verificarPermiso('BuscarVentasClientes');

        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        $gestor = new GestorClientes();

        if ($busqueda->load(Yii::$app->request->post()) && $busqueda->validate()) {
            $estado = $busqueda->Combo ? $busqueda->Combo : 'T';
            $estadoVenta = $busqueda->Combo2 ? $busqueda->Combo2 : 'T';
            $fechaInicio = $busqueda->FechaInicio;
            $fechaFin = $busqueda->FechaFin;
            $mora = $busqueda->Combo3 ? $busqueda->Combo3 : 'N';
            $idCliente = $busqueda->Id ? $busqueda->Id : $id;
            $clientes = $gestor->BuscarVentas($idCliente, $fechaInicio, $fechaFin, $estado, $estadoVenta, $mora);
        } else {
            $busqueda->FechaInicio = FechaHelper::formatearDateLocal(date("Y-m-d", strtotime(date("Y-m-d", strtotime(date("Y-m-d"))) . "-1 year")));
            $busqueda->FechaFin = FechaHelper::dateActualLocal();
            $clientes = $gestor->BuscarVentas($id, $busqueda->FechaInicio, $busqueda->FechaFin);
        }

        $paginado->totalCount = count($clientes);
        $clientes = array_slice($clientes, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        $cls = $gestor->Buscar();
        $clsout = [];

        foreach ($cls as $cl) {
            $clsout[$cl['IdCliente']] = Clientes::Nombre($cl);
        }

        return $this->render('ventas', [
            'models' => $clientes,
            'busqueda' => $busqueda,
            'paginado' => $paginado,
            'clientes' => $clsout,
            'ocultarId' => $id != 0
        ]);
    }
}
