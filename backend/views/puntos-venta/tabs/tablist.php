<?php

use common\components\PermisosHelper;

?>

<?php foreach($tabs as $tab): ?>
    <?php if (PermisosHelper::tienePermiso($tab['Permiso'])): ?>
        <li class="nav-item">
            <a class="nav-link" href="#" ref="<?= $tab['Nombre'] ?>" @click="setTab('<?= $tab['Nombre'] ?>')">
                <?= $tab['Nombre'] ?>
            </a>
        </li>
    <?php endif; ?>
<?php endforeach; ?>
