<?php

namespace frontend\modules\api;

use yii\base\BootstrapInterface;

class Bootstrap implements BootstrapInterface
{
    public function bootstrap($app)
    {
        $app->getUrlManager()->addRules(
                require(__DIR__ . '/routes.php'
                ),
            false
        );
    }
}
