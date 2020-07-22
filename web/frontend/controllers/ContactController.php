<?php
namespace frontend\controllers;

use yii\web\Controller;
use frontend\models\forms\ContactForm;
use common\components\EmailHelper;
use Yii;

/**
 * Contact controller
 */
class ContactController extends Controller
{
    public function actionIndex()
    {
        $model = new ContactForm;

        if ($model->load(Yii::$app->request->post()) && $model->validate()) {
            try {
                EmailHelper::enviarEmail('Contact <contact@forta.xyz>', 'liezun.js@gmail.com', 'Contact Form Numio.xyz', 'contact', [
                    'model' => $model
                ]);
                Yii::$app->session->setFlash('success', 'We received your message. We\'ll get in touch soon.');
                // Clean contact form
                $model = new ContactForm;
            } catch (\Exception $e) {
                Yii::$app->session->setFlash('error', 'An error ocurred, try again later.');
            }
        }

        return $this->render('index', [
            'model' => $model
        ]);
    }

    public function actionCreate()
    {
        $model = new ContactForm;
    }
}
