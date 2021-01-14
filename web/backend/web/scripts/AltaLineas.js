"use strict";
var AltaLineas = {
  init: function (urlBase, tipoPrecio, model, lineas, configMoney) {
    var id = model.IdIngreso ? model.IdIngreso : model.IdVenta;
    var idPadre = model.IdIngreso ? model.IdRemito : model.IdVenta;
    var idCliente = model.IdIngreso ? 0 : model.IdCliente;
    new Vue({
      el: "#lineas",
      data: function () {
        return {
          ingreso: model,
          lineas: lineas,
          options: [],
          cantidad: "",
          // flag de sincronizacion
          agregando: false,
        };
      },
      computed: {
        total: function () {
          var sum = 0;
          this.lineas.forEach((l) => {
            sum += parseFloat(l.Cantidad) * parseFloat(l.Precio);
          });
          return sum.toFixed(2);
        },
      },
      mounted: function () {
        this.configurarAjax();
        this.actualizarLineas();
      },
      methods: {
        limpiar: function () {
          $(this.$refs.articulo).val(null).trigger("change").select2("open");
          this.cantidad = "";
          $(this.$refs.precio).val("");
        },
        acumularLineas: function () {
          var mapLineas = {};
          this.lineas.forEach((l) => {
            if (!mapLineas[l.IdArticulo]) {
              mapLineas[l.IdArticulo] = [];
            }
            mapLineas[l.IdArticulo].push(l);
          });
          var listadoFinal = [];
          Object.keys(mapLineas).forEach((id) => {
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
        actualizarLineas: function () {
          for (let i = 0; i < this.lineas.length; i++) {
            $(this.$refs.precio[i]).val(this.lineas[i].Precio);
          }
          if (model.IdVenta) {
            _this.acumularLineas();
          }
        },
        agregar: function () {
          this.doAgregar();
        },
        doAgregar: function (optionalCallback) {
          if (this.agregando) {
            return;
          }
          var _this = this;
          var idArticulo = $(this.$refs.articulo).val();
          var precio = $(this.$refs.precio).val();
          if (!String(precio).trim()) {
            precio = 0;
          }
          this.agregando = true;
          $.post(urlBase + "/agregar-linea/" + id, {
            LineasForm: {
              IdArticulo: idArticulo,
              Cantidad: this.cantidad,
              Precio: precio,
            },
          })
            .done(function (data) {
              _this.agregando = false;
              let error = false;
              if (data.error) {
                _this.mostrarMensaje("danger", data.error, "ban");
                error = true;
              } else {
                _this.lineas.push({
                  Articulo: _this.options.find(
                    (a) => String(a.IdArticulo) === String(idArticulo)
                  ).Articulo,
                  IdArticulo: idArticulo,
                  Cantidad: parseFloat(_this.cantidad).toFixed(2),
                  Precio: parseFloat(precio).toFixed(2),
                });
                _this.acumularLineas();
                _this.limpiar();
              }
              if (optionalCallback) {
                optionalCallback(error);
              }
            })
            .catch(function (err) {
              _this.agregando = false;
              console.log(err);
              _this.mostrarMensaje(
                "danger",
                "Error en la comunicación con el servidor.",
                "ban"
              );
              if (optionalCallback) {
                optionalCallback(true);
              }
            });
        },
        borrarLinea: function (i) {
          var _this = this;
          $.post(urlBase + "/quitar-linea/" + id, {
            IdArticulo: this.lineas[i].IdArticulo,
          })
            .done(function (data) {
              if (data.error) {
                _this.mostrarMensaje("danger", data.error, "ban");
              } else {
                _this.lineas.splice(i, 1);
              }
            })
            .catch(function (err) {
              console.log(err);
              _this.mostrarMensaje(
                "danger",
                "Error en la comunicación con el servidor.",
                "ban"
              );
            });
        },
        editarLinea: function (i) {
          var _this = this;
          var uri = urlBase + "/editar-linea/" + id;
          var precio = $(this.$refs.precio[i]).val();
          $.post(urlBase + "/editar-linea/" + id, {
            LineasForm: {
              IdArticulo: _this.lineas[i].IdArticulo,
              Cantidad: _this.lineas[i].Cantidad,
              Precio: precio,
            },
          })
            .done(function (data) {
              if (data.error) {
                _this.mostrarMensaje("danger", data.error, "ban");
              } else {
                _this.mostrarMensaje("success", "Actualizado", "check");
                _this.lineas[i].Precio = precio;
                _this.limpiar();
                _this.actualizarLineas();
              }
            })
            .catch(function (err) {
              console.log(err);
              _this.mostrarMensaje(
                "danger",
                "Error en la comunicación con el servidor.",
                "ban"
              );
            });
        },
        mostrarMensaje: function (tipo, mensaje, icono) {
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
        completar: function () {
          // Si hay una línea en borrador, intento agregarla
          var idArticulo = $(this.$refs.articulo).val();
          if (idArticulo) {
            this.doAgregar((err) => {
              if (!err) {
                this.doCompletar();
              }
            });
          } else {
            this.doCompletar();
          }
        },
        doCompletar: function () {
          var _this = this;
          var uri =
            (model.IdRemito ? "/remitos" : urlBase) + "/activar/" + idPadre;
          $.ajax(uri)
            .done(function (data) {
              if (data.error) {
                _this.mostrarMensaje("danger", data.error, "ban");
              } else {
                if (model.IdVenta) {
                  window.open("/pagos/" + id, "_self");
                } else {
                  window.open(
                    "/puntos-venta/operaciones/" +
                    _this.ingreso.IdPuntoVenta +
                    "?tab=" +
                    (model.IdRemito ? "Remitos" : "Ventas"),
                    "_self"
                  );
                }
              }
            })
            .catch(function (err) {
              console.log(err);
              _this.mostrarMensaje(
                "danger",
                "Error en la comunicación con el servidor.",
                "ban"
              );
            });
        },
        ingresar: function () {
          // Si hay una línea en borrador, intento agregarla
          var idArticulo = $(this.$refs.articulo).val();
          if (idArticulo) {
            this.doAgregar((err) => {
              if (!err) {
                this.doIngresar();
              }
            });
          } else {
            this.doIngresar();
          }
        },
        doIngresar: function () {
          var _this = this;
          var uri =
            (model.IdRemito ? "/remitos" : urlBase) + "/ingresar/" + idPadre;
          $.ajax(uri)
            .done(function (data) {
              if (data.error) {
                _this.mostrarMensaje("danger", data.error, "ban");
              } else {
                if (model.IdVenta) {
                  window.open("/pagos/" + id, "_self");
                } else {
                  window.open(
                    "/puntos-venta/operaciones/" +
                    _this.ingreso.IdPuntoVenta +
                    "?tab=" +
                    (model.IdRemito ? "Remitos" : "Ventas"),
                    "_self"
                  );
                }
              }
            })
            .catch(function (err) {
              console.log(err);
              _this.mostrarMensaje(
                "danger",
                "Error en la comunicación con el servidor.",
                "ban"
              );
            });
        },
        configurarAjax: function () {
          var _this = this;
          // $(this.$refs.precio).maskMoney(configMoney);
          $(this.$refs.articulo)
            .select2({
              width: "100%",
              minimumInputLength: 3,
              language: "es",
              ajax: {
                url: "/articulos/listar",
                dataType: "json",
                data: function (params) {
                  var query = {
                    id: idCliente,
                    Cadena: params.term || "",
                  };
                  return query;
                },
                processResults: function (data) {
                  var items = [];
                  _this.options = data;
                  data.forEach(function (art) {
                    items.push({
                      id: art["IdArticulo"],
                      text: art["Articulo"],
                    });
                  });
                  return {
                    results: items,
                  };
                },
              },
              language: {
                noResults: function () {
                  return "No hay resultados";
                },
                searching: function () {
                  return "Buscando...";
                },
                inputTooShort: function (args) {
                  var remainingChars = args.minimum - args.input.length;

                  var message =
                    "Por favor, ingrese " +
                    remainingChars +
                    " o más caracteres";

                  return message;
                },
                errorLoading: function () {
                  return "No se pudieron obtener resultados";
                },
              },
            })
            .on("select2:select", function (e) {
              for (var i = 0; i < _this.options.length; i++) {
                if (
                  String(_this.options[i].IdArticulo) === String(e.target.value)
                ) {
                  $(_this.$refs.precio).val(_this.options[i][tipoPrecio]);
                  break;
                }
              }
            });
        },
      },
    });
  },
};
