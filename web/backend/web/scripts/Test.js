var Pagos = {
  /*
    // Clave - Valor
    allFlieds = [
        "monto", "nrotarjeta", "mesvencimiento", ... etc
    ]
    ,
    showFliedsForPaymentMethod = {
        // Efectivo
        "1" = {
            showFields = [
                "monto"
            ]
        },
        // Tarjeta
        "3" = {
            showFields = [
                "monto", "nrotarjeta", "mesvencimiento", ... etc
            ]
        }
    }
    */
  init: function (allFlieds, showFliedsForPaymentMethod) {
    (function () {
      function hideField(name) {
        if ($("#pagos-" + name)) {
          $("#pagos-" + name).val(0);
          $(".field-pagos-" + name).hide();
        } else {
          $("#pagos-" + name).val("");
          $(".field-pagos-" + name).hide();
        }
        return true;
      }

      function showField(name) {
        $(".field-pagos-" + name).show();
        return true;
      }

      function controlarTipoPago() {
        let MedioPago = parseInt($("#pagos-idmediopago").val());
        allFlieds.forEach((key) => {
          if (showFliedsForPaymentMethod[MedioPago].includes(key)) {
            showField(key);
          } else {
            hideField(key);
          }
        });
      }

      $("#pagos-idmediopago").change(function () {
        controlarTipoPago();
        for (const key in allFlieds) {
          $("#w0").yiiActiveForm("validateAttribute", "pagos-" + key);
        }
      });

      $("#pagos-idmediopago").keyup(function () {
        controlarTipoPago();
        for (const key in allFlieds) {
          $("#w0").yiiActiveForm("validateAttribute", "pagos-" + key);
        }
      });

      controlarTipoPago();

      function actualizarDescuento() {
        $("#pagos-descuento").val(
          ($("#pagos-monto").val() / $("#pagos-montoventa").val()) * 100
        );
        return false;
      }

      $("#pagos-monto").change(function () {
        if (parseInt($("#pagos-idmediopago").val()) == 8) {
          actualizarDescuento();
        }
        $("#w0").yiiActiveForm("validateAttribute", "pagos-monto");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-descuento");
      });

      $("#pagos-monto").keyup(function () {
        if (parseInt($("#pagos-idmediopago").val()) == 8) {
          actualizarDescuento();
        }
        $("#w0").yiiActiveForm("validateAttribute", "pagos-monto");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-descuento");
      });

      function actualizarMonto() {
        $("#pagos-monto").val(
          ($("#pagos-montoventa").val() * $("#pagos-descuento").val()) / 100
        );
        return false;
      }

      $("#pagos-descuento").change(function () {
        if (parseInt($("#pagos-idmediopago").val()) == 8) {
          actualizarMonto();
        }
        $("#w0").yiiActiveForm("validateAttribute", "pagos-monto");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-descuento");
      });

      $("#pagos-descuento").keyup(function () {
        if (parseInt($("#pagos-idmediopago").val()) == 8) {
          actualizarMonto();
        }
        $("#w0").yiiActiveForm("validateAttribute", "pagos-monto");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-descuento");
      });
    })();
  },
};
