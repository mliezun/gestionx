<?php

namespace backend\controllers;

use common\models\forms\BuscarForm;
use common\components\PermisosHelper;
use Yii;
use yii\web\Controller;
use yii\data\Pagination;
use yii\helpers\ArrayHelper;
use yii\web\ForbiddenHttpException;

class BaseController extends Controller
{
    public function beforeAction($action)
    {
        if (!Yii::$app->user->isGuest && isset(Yii::$app->user->identity->IdPuntoVenta)) {
            $actionsPV = [
                'puntos-venta',
                'ingresos',
                'remitos',
                'ventas',
                'cheques',
                'articulos',
                'rectificaciones',
                'pagos',
                'usuarios/logout',
                'usuarios/cambiar-password',
                'articulos/listar'
            ];
            foreach ($actionsPV as $actionPV) {
                if (substr($action->uniqueId, 0, strlen($actionPV)) === $actionPV) {
                    return true;
                }
            }
            $this->redirect(array('puntos-venta/operaciones/' . Yii::$app->user->identity->IdPuntoVenta));
            return false;
        }

        return true;
    }

    /**
     * Genera la vista de listado de elementos de un modelo específico.
     *
     * @param gestor Gestor que implementa el método Buscar, el cual retorna un listado de elementos.
     * @param buscar Listado de atributos de la clase BuscarForm que se tienen en cuenta como filtros.
     */
    protected function index($gestor, $buscar)
    {
        $paginado = new Pagination();
        $paginado->pageSize = Yii::$app->session->get('Parametros')['CANTFILASPAGINADO'];

        $busqueda = new BuscarForm();

        if ($busqueda->load(Yii::$app->request->get()) && $busqueda->validate()) {
            $paramsBuscar = array();
            foreach ($buscar as $b) {
                $paramsBuscar[] = $busqueda[$b];
            }
            $elems = call_user_func_array(array($gestor, 'Buscar'), $paramsBuscar);
        } else {
            $elems = $gestor->Buscar();
        }

        $paginado->totalCount = count($elems);
        $elems = array_slice($elems, $paginado->page * $paginado->pageSize, $paginado->pageSize);

        return $this->render('index', [
            'models' => $elems,
            'busqueda' => $busqueda,
            'paginado' => $paginado
        ]);
    }

    /**
     * Permite generar la vista de alta de un modelo.
     *
     * @param model Un objeto que implemente la clase Model de yii.
     * @param accion array(gestor, metodo) que se ejecutará sobre el modelo.
     * @param mostrar Función que se ejecutará en caso que el pedido sea un GET.
     * @param view Vista que se renderizará.
     */
    protected function alta($model, $accion, $mostrar, $view = 'alta')
    {
        if ($model->load(Yii::$app->request->post()) && $model->validate()) {
            Yii::$app->response->format = 'json';
            $resultado = call_user_func_array($accion, array($model));

            if (\substr($resultado, 0, 2) != 'OK') {
                return ['error' => $resultado];
            }

            return ['error' => null];
        }

        ($mostrar)();

        return $this->renderAjax($view, [
            'model' => $model
        ]);
    }

    /**
     * Permite cambiar el estado de un modelo.
     *
     * @param model Un objeto que implemente la clase Model de yii.
     * @param operacion Método que se ejecutará sobre el objeto.
     */
    protected function cambiarEstado($model, $operacion)
    {
        Yii::$app->response->format = 'json';

        $resultado = call_user_func_array(array($model, $operacion), array());

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }

    /**
     * Permite aplicar una operación del gestor sobre un modelo.
     *
     * @param model Un objeto que implemente la clase Model de yii.
     * @param accion array(gestor, metodo) que se ejecutará sobre el modelo.
     */
    protected function aplicarOperacionGestor($model, $accion)
    {
        Yii::$app->response->format = 'json';

        $resultado = call_user_func_array($accion, array($model));

        if ($resultado == 'OK') {
            return ['error' => null];
        } else {
            return ['error' => $resultado];
        }
    }
}
