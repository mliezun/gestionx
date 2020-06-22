var Roles = {};

Roles.Permisos = {
    init: function () {
        // Árbol de permisos
        $('.tree-container .tree-grupo').each(function (index, element) {
            Roles.Permisos.estadoCheckPadre(element);
        });

        // Marcar o desmarcar los hijos
        $('.tree-container .tree-grupo').on('change', function () {
            var estado = $(this).is(':checked');
            $(this).closest('li').find(':checkbox').prop('checked', estado);
        });
    },
    estadoCheckPadre: function (elemento) {
        var seleccionado = true;
        $(elemento).closest('li').find('.tree-hoja:checkbox').each(function () {
            if (seleccionado && !$(this).is(':checked'))
                seleccionado = false
        });
        $(elemento).prop('checked', seleccionado);
    }
};
