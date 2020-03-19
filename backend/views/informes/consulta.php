
SELECT
<?php foreach($informe['SELECT'] as $tabla => $columnas): ?>
    <?php foreach($columnas as $columna): ?>
        <?= $tabla ?>.<?= $columna ?>
    <?php endforeach; ?>
<?php endforeach; ?>

FROM
<?php $tablaAnterior = null; ?>
<?php foreach($informe['FROM'] as $tabla => $columnas): ?>
    <?php if (!isset($tablaAnterior)): ?>
        <?php
        $tablaAnterior = $tabla;
        echo $tabla;
        ?>
    <?php else: ?>
        ON
        <?php foreach($columnas as $i => $columna): ?>
            <?= $tabla ?>.<?= $columna ?>=<?= $tablaAnterior ?>.<?= $columna ?>
            <?php if ($i+1 != count($columnas)): ?>
            AND
            <?php endif; ?>
        <?php endforeach; ?>
    <?php endif; ?>
<?php endforeach; ?>

WHERE
<?php foreach($informe['WHERE'] as $tabla => $columnas): ?>
    <?php foreach($columnas as $columna => $cond): ?>
        <?= $tabla ?>.<?= $columna ?> <?= $cond ?>
        <?php if ($i+1 != count($columnas)): ?>
        AND
        <?php endif; ?>
    <?php endforeach; ?>
<?php endforeach; ?>
