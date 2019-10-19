"use strict";
var AltaLineas = {
  init: function(urlBase, tipoPrecio, model, lineas, configMoney) {
    var id = model.IdIngreso ? model.IdIngreso : model.IdVenta;
    var idPadre = model.IdIngreso ? model.IdRemito : model.IdVenta;
    var idCliente = model.IdIngreso ? 0 : model.IdCliente;
    new Vue({
      el: "#lineas",
      data: function() {
        return {
          ingreso: model,
          lineas: lineas,
          options: [],
          cantidad: ""
        };
      },
      computed: {
        total: function() {
          var sum = 0;
          this.lineas.forEach(l => {
            sum += parseFloat(l.Cantidad) * parseFloat(l.Precio);
          });
          return sum.toFixed(2);
        }
      },
      mounted: function() {
        this.configurarAjax();
      },
      methods: {
        limpiar: function() {
          $(this.$refs.articulo)
            .val(null)
            .trigger("change")
            .select2("open");
          this.cantidad = "";
          $(this.$refs.precio).val("");
        },
        acumularLineas: function() {
          var mapLineas = {};
          this.lineas.forEach(l => {
            if (!mapLineas[l.IdArticulo]) {
              mapLineas[l.IdArticulo] = [];
            }
            mapLineas[l.IdArticulo].push(l);
          });
          var listadoFinal = [];
          Object.keys(mapLineas).forEach(id => {
            listadoFinal.push(
              mapLineas[id].reduce((l1, l2) => {
                l1.Cantidad = (
                  parseFloat(l1.Cantidad) + parseFloat(l2.Cantidad)
                ).toFixed(2);
                return l1;
              })
            );
          });
          this.lineas = listadoFinal;
        },
        agregar: function() {
          var _this = this;
          var idArticulo = $(this.$refs.articulo).val();
          var precio = $(this.$refs.precio)
            .val()
            .replace(".", "")
            .replace(",", ".");
          $.post(urlBase + "/agregar-linea/" + id, {
            LineasForm: {
              IdArticulo: idArticulo,
              Cantidad: this.cantidad,
              Precio: precio
            }
          })
            .done(function(data) {
              if (data.error) {
                _this.mostrarMensaje("danger", data.error, "ban");
              } else {
                _this.lineas.push({
                  Articulo: _this.options.find(
                    a => String(a.IdArticulo) === String(idArticulo)
                  ).Articulo,
                  IdArticulo: idArticulo,
                  Cantidad: parseFloat(_this.cantidad).toFixed(2),
                  Precio: parseFloat(precio).toFixed(2)
                });
                _this.acumularLineas();
                _this.limpiar();
              }
            })
            .catch(function(err) {
              console.log(err);
              _this.mostrarMensaje(
                "danger",
                "Error en la comunicación con el servidor.",
                "ban"
              );
            });
        },
        borrarLinea: function(i) {
          var _this = this;
          $.post(urlBase + "/quitar-linea/" + id, {
            IdArticulo: this.lineas[i].IdArticulo
          })
            .done(function(data) {
              if (data.error) {
                _this.mostrarMensaje("danger", data.error, "ban");
              } else {
                _this.lineas.splice(i, 1);
              }
            })
            .catch(function(err) {
              console.log(err);
              _this.mostrarMensaje(
                "danger",
                "Error en la comunicación con el servidor.",
                "ban"
              );
            });
        },
        mostrarMensaje: function(tipo, mensaje, icono) {
          var html =
            '<div id="mensaje" class="alert alert-' +
            tipo +
            ' alert-dismissable">' +
            '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>' +
            '<i class="fa fa-' +
            icono +
            '"></i> ' +
            '<b class="texto" >' +
            mensaje +
            "</b>" +
            "</div>";
          $("#errores").html(html);
        },
        completar: function() {
          var _this = this;
          var uri =
            (model.IdRemito ? "/remitos" : urlBase) + "/activar/" + idPadre;
          $.ajax(uri)
            .done(function(data) {
              if (data.error) {
                _this.mostrarMensaje("danger", data.error, "ban");
              } else {
                window.open(
                  "/puntos-venta/operaciones/" +
                    _this.ingreso.IdPuntoVenta +
                    "?tab=" +
                    (model.IdRemito ? "Remitos" : "Ventas"),
                  "_self"
                );
              }
            })
            .catch(function(err) {
              console.log(err);
              _this.mostrarMensaje(
                "danger",
                "Error en la comunicación con el servidor.",
                "ban"
              );
            });
        },
        configurarAjax: function() {
          var _this = this;
          $(this.$refs.precio).maskMoney(configMoney);
          $(this.$refs.articulo)
            .select2({
              width: "100%",
              minimumInputLength: 3,
              language: "es",
              ajax: {
                url: "/articulos/listar",
                dataType: "json",
                data: function(params) {
                  var query = {
                    id: idCliente,
                    Cadena: params.term || ""
                  };
                  return query;
                },
                processResults: function(data) {
                  var items = [];
                  _this.options = data;
                  data.forEach(function(art) {
                    items.push({
                      id: art["IdArticulo"],
                      text: art["Articulo"]
                    });
                  });
                  return {
                    results: items
                  };
                }
              },
              language: {
                noResults: function() {
                  return "No hay resultados";
                },
                searching: function() {
                  return "Buscando...";
                },
                inputTooShort: function(args) {
                  var remainingChars = args.minimum - args.input.length;

                  var message =
                    "Por favor, ingrese " +
                    remainingChars +
                    " o más caracteres";

                  return message;
                },
                errorLoading: function() {
                  return "No se pudieron obtener resultados";
                }
              }
            })
            .on("select2:select", function(e) {
              for (var i = 0; i < _this.options.length; i++) {
                if (
                  String(_this.options[i].IdArticulo) === String(e.target.value)
                ) {
                  $(_this.$refs.precio).val(_this.options[i][tipoPrecio]);
                  break;
                }
              }
            });
        }
      }
    });
  }
};
