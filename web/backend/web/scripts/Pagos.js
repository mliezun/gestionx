var Pagos = {
  init: function () {
    (function () {
      function controlarTipoPago() {
        switch (parseInt($("#pagos-idmediopago").val())) {
          // Efectivo - Deposito
          case 1:
          case 6:
            $(".field-pagos-monto").show();

            $("#pagos-nrotarjeta").val("");
            $(".field-pagos-nrotarjeta").hide();
            $("#pagos-mesvencimiento").val("");
            $(".field-pagos-mesvencimiento").hide();
            $("#pagos-aniovencimiento").val("");
            $(".field-pagos-aniovencimiento").hide();
            $("#pagos-ccv").val("");
            $(".field-pagos-ccv").hide();
            $("#pagos-idremito").val(0);
            $(".field-pagos-idremito").hide();
            $("#pagos-idcheque").val(0);
            $(".field-pagos-idcheque").hide();
            $("#pagos-idtipotributo").val(0);
            $(".field-pagos-idtipotributo").hide();
            $(".field-pagos-descuento").hide();
            return true;
          // Mercaderia
          case 2:
            $(".field-pagos-idremito").show();

            $("#pagos-monto").val(0);
            $(".field-pagos-monto").hide();
            $("#pagos-nrotarjeta").val("");
            $(".field-pagos-nrotarjeta").hide();
            $("#pagos-mesvencimiento").val("");
            $(".field-pagos-mesvencimiento").hide();
            $("#pagos-aniovencimiento").val("");
            $(".field-pagos-aniovencimiento").hide();
            $("#pagos-ccv").val("");
            $(".field-pagos-ccv").hide();
            $("#pagos-idcheque").val(0);
            $(".field-pagos-idcheque").hide();
            $("#pagos-idtipotributo").val(0);
            $(".field-pagos-idtipotributo").hide();
            $(".field-pagos-descuento").hide();
            return true;
          // Tarjeta
          case 3:
            $(".field-pagos-monto").show();
            $(".field-pagos-nrotarjeta").show();
            $(".field-pagos-mesvencimiento").show();
            $(".field-pagos-aniovencimiento").show();
            $(".field-pagos-ccv").show();

            $("#pagos-idremito").val(0);
            $(".field-pagos-idremito").hide();
            $("#pagos-idcheque").val(0);
            $(".field-pagos-idcheque").hide();
            $("#pagos-idtipotributo").val(0);
            $(".field-pagos-idtipotributo").hide();
            $(".field-pagos-descuento").hide();
            return true;
          // Cheque
          case 5:
            $(".field-pagos-idcheque").show();

            $("#pagos-monto").val(0);
            $(".field-pagos-monto").hide();
            $("#pagos-nrotarjeta").val("");
            $(".field-pagos-nrotarjeta").hide();
            $("#pagos-mesvencimiento").val("");
            $(".field-pagos-mesvencimiento").hide();
            $("#pagos-aniovencimiento").val("");
            $(".field-pagos-aniovencimiento").hide();
            $("#pagos-ccv").val("");
            $(".field-pagos-ccv").hide();
            $("#pagos-idremito").val(0);
            $(".field-pagos-idremito").hide();
            $("#pagos-idtipotributo").val(0);
            $(".field-pagos-idtipotributo").hide();
            $(".field-pagos-descuento").hide();
            return true;
          // Retencion
          case 7:
            $(".field-pagos-monto").show();
            $(".field-pagos-idtipotributo").show();

            $("#pagos-nrotarjeta").val("");
            $(".field-pagos-nrotarjeta").hide();
            $("#pagos-mesvencimiento").val("");
            $(".field-pagos-mesvencimiento").hide();
            $("#pagos-aniovencimiento").val("");
            $(".field-pagos-aniovencimiento").hide();
            $("#pagos-ccv").val("");
            $(".field-pagos-ccv").hide();
            $("#pagos-idremito").val(0);
            $(".field-pagos-idremito").hide();
            $("#pagos-idcheque").val(0);
            $(".field-pagos-idcheque").hide();
            $(".field-pagos-descuento").hide();
            return true;
          // Descuento
          case 8:
            $(".field-pagos-monto").show();
            $(".field-pagos-descuento").show();

            $("#pagos-nrotarjeta").val("");
            $(".field-pagos-nrotarjeta").hide();
            $("#pagos-mesvencimiento").val("");
            $(".field-pagos-mesvencimiento").hide();
            $("#pagos-aniovencimiento").val("");
            $(".field-pagos-aniovencimiento").hide();
            $("#pagos-ccv").val("");
            $(".field-pagos-ccv").hide();
            $("#pagos-idremito").val(0);
            $(".field-pagos-idremito").hide();
            $("#pagos-idcheque").val(0);
            $(".field-pagos-idcheque").hide();
            $("#pagos-idtipotributo").val(0);
            $(".field-pagos-idtipotributo").hide();
            return true;
          default:
            break;
        }
        // Efectivo - Deposito
        $("#pagos-monto").val(0);
        $(".field-pagos-monto").hide();

        // Tarjeta
        $("#pagos-nrotarjeta").val("");
        $(".field-pagos-nrotarjeta").hide();
        $("#pagos-mesvencimiento").val("");
        $(".field-pagos-mesvencimiento").hide();
        $("#pagos-aniovencimiento").val("");
        $(".field-pagos-aniovencimiento").hide();
        $("#pagos-ccv").val("");
        $(".field-pagos-ccv").hide();

        // Mercaderia
        $("#pagos-idremito").val(0);
        $(".field-pagos-idremito").hide();

        // Cheque
        $("#pagos-idcheque").val(0);
        $(".field-pagos-idcheque").hide();

        // Retencion
        $("#pagos-idtipotributo").val(0);
        $(".field-pagos-idtipotributo").hide();

        // Descuento
        $("#pagos-descuento").val(0);
        $(".field-pagos-descuento").hide();
        return false;
      }

      $("#pagos-idmediopago").change(function () {
        controlarTipoPago();
        $("#w0").yiiActiveForm("validateAttribute", "pagos-monto");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-nrotarjeta");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-mesvencimiento");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-aniovencimiento");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-ccv");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idremito");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idcheque");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idtipotributo");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-descuento");
      });

      $("#pagos-idmediopago").keyup(function () {
        controlarTipoPago();
        $("#w0").yiiActiveForm("validateAttribute", "pagos-monto");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-nrotarjeta");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-mesvencimiento");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-aniovencimiento");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-ccv");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idremito");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idcheque");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-idtipotributo");
        $("#w0").yiiActiveForm("validateAttribute", "pagos-descuento");
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
