<?php

use common\components\PermisosHelper;

?>

<?php foreach($tabs as $tab): ?>
    <?php if (PermisosHelper::tienePermiso($tab['Permiso'])): ?>
        <div    id="<?= $tab['Nombre'] ?>"
                class="tab-pane fade active show"
                role="tabpanel"
                aria-labelledby="<?= $tab['Nombre'] ?>-tab"
        >
            <?= $tab['Render']() ?>
        </div>
    <?php endif; ?>
<?php endforeach; ?>
