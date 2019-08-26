<?php

namespace backend\controllers;

use common\models\Usuarios;
use common\models\Clientes;
use common\models\GestorClientes;
use common\models\GestorListasPrecio;
use common\models\forms\BuscarForm;
use common\models\forms\AuditoriaForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;

class ClientesController extends Controller
{
    public function actionIndex()
    {
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
            'busqueda' => $busqueda
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

        $listas = GestorListasPrecio::Buscar();

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
            return $this->renderAjax('alta', [
                'titulo' => 'Alta Cliente',
                'model' => $cliente,
                'listas' => $listas
            ]);
        }
    }

    public function actionEditar($id)
    {
        PermisosHelper::verificarPermiso('ModificarCliente');
        
        $cliente = new Clientes();

        $clienteAux = new Clientes();
        $clienteAux->IdCliente = $id;
        $clienteAux->Dame();
        if ($clienteAux->Tipo == 'F') {
            $cliente->setScenario(Clientes::_MODIFICAR_FISICA);
        } else {
            $cliente->setScenario(Clientes::_MODIFICAR_JURIDICA);
        }
        
        $listas = GestorListasPrecio::Buscar();

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
            return $this->renderAjax('alta', [
                        'titulo' => 'Editar Cliente',
                        'model' => $clienteAux,
                        'listas' => $listas
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
}

?>