<?php

use common\components\PermisosHelper;

?>

<?php foreach($tabs as $tab): ?>
    <?php if (PermisosHelper::tienePermiso($tab['Permiso'])): ?>
        <li class="nav-item">
            <a  id="<?= $tab['Nombre'] ?>-tab"
                href="#<?= $tab['Nombre'] ?>"
                class="nav-link active show"
                data-toggle="tab"
                role="tab"
                aria-controls="<?= $tab['Nombre'] ?>"
                aria-selected="false"
            >
                <?= $tab['Nombre'] ?>
            </a>
        </li>
    <?php endif; ?>
<?php endforeach; ?>
