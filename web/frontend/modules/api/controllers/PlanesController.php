<?php
namespace frontend\modules\api\controllers;

use Yii;
use yii\helpers\ArrayHelper;
use common\models\Planes;
use common\models\GestorPlanes;

class PlanesController extends BaseController
{
    /**
     * @api {get} /planes Listar planes
     * @apiName ListaPlanes
     * @apiGroup Planes
     * @apiPermission logueado
     *
     * @apiParam {String} Estado Estado de los planes a buscar: A o B
     *
     * @apiSuccess {Int} Planes.IdPlan Identificador del Plan
     * @apiSuccess {String} Planes.Plan Nombre del Plan.
     * @apiSuccess {Int} Planes.CantDias Cantidad de días que otorga el Plan.
     * @apiSuccess {Decimal} Planes.Precio Precio del plan.
     * @apiSuccess {String} Planes.Descripcion Descripcion del cliente.
     * @apiError {String} Error Mensaje de error.
     */
    public function actionIndex()
    {
        $Estado = Yii::$app->request->get('Estado');

        $listado = [];
        
        $gestor = new GestorPlanes();

        if (isset($Estado)) {
            $listado = $gestor->ListarPlanes($Estado);
        } else {
            $listado = $gestor->ListarPlanes();
        }
        
                
        $out = [];
        if (count($listado) == 1 && array_key_exists('Mensaje', $listado[0])) {
            throw new ForbiddenHttpException($listado[0]['Mensaje']);
        }
        foreach ($listado as $u) {
            $out[] = [
                'IdPlan' => $u['IdPlan'],
                'Plan' => $u['Plan'],
                'CantDias' => $u['CantDias'],
                'Precio' => $u['Precio'],
                'Descripcion' => $u['Descripcion'],
            ];
        }

        return $out;
    }

    /**
     * @api {get} /planes/:id Get Plan
     * @apiName GetPlan
     * @apiGroup Planes
     * @apiPermission logueado
     *
     * @apiParam {Entero} IdPlan Identificar del PLAN.
     *
     * @apiError {String} Error Mensaje de error.
     */
    public function actionView($id)
    {
        $plan = new Planes();
        $plan->IdPlan = $id;

        $Codigo = Yii::$app->request->get('Codigo');
        if (!isset($Codigo)) {
            $Codigo = '';
        }
        $plan->Dame($Codigo);

        return $plan;
    }
}
