"use strict";
var AltaLineas = {
    init: function (model, lineas) {
        Vue.component('v-select', VueSelect.VueSelect);
        new Vue({
            el: '#lineas',
            data: function () {
                return {
                    ingreso: model,
                    lineasIngreso: lineas,
                    options: [],
                    cantidad: '',
                    precio: '',
                    articulo: null
                };
            },
            computed: {
                total: function () {
                    var sum = 0;
                    this.lineasIngreso.forEach(l => {
                        sum += parseFloat(l.Cantidad) * parseFloat(l.Precio);
                    })
                    return sum.toFixed(2);
                }
            },
            methods: {
                /**
                 * Triggered when the search text changes.
                 *
                 * @param search  {String}    Current search text
                 * @param loading {Function}	Toggle loading class
                 */
                fetchOptions: function (search, loading) {
                    var _this = this;
                    loading(true);
                    $.get('/articulos/listar?Cadena=' + search)
                        .done(function (data) {
                            setTimeout(function () {
                                loading(false);
                            }, 1000);
                            _this.options = data;
                        })
                        .catch(function (err) {
                            console.log(err);
                            setTimeout(function () {
                                loading(false);
                            }, 1000);
                        })
                },
                limpiar: function () {
                    this.cantidad = '';
                    this.precio = '';
                    this.articulo = null;
                    this.$refs.articulo.clearSelection();
                },
                acumularLineas: function () {
                    var mapLineas = {};
                    this.lineasIngreso.forEach(l => {
                        if (!mapLineas[l.IdArticulo]) {
                            mapLineas[l.IdArticulo] = []
                        }
                        mapLineas[l.IdArticulo].push(l)
                    });
                    var listadoFinal = []
                    Object.keys(mapLineas).forEach(id => {
                        listadoFinal.push(mapLineas[id].reduce((l1, l2) => {
                            l1.Cantidad = (parseFloat(l1.Cantidad) + parseFloat(l2.Cantidad)).toFixed(2);
                            return l1;
                        }));
                    });
                    this.lineasIngreso = listadoFinal;
                },
                agregar: function () {
                    var _this = this;
                    $.post('/ingresos/agregar-linea/' + this.ingreso.IdIngreso, {
                        LineasForm: {
                            IdArticulo: this.articulo,
                            Cantidad: this.cantidad,
                            Precio: this.precio
                        }
                    })
                        .done(function (data) {
                            if (data.error) {
                                _this.mostrarMensaje('danger', data.error, 'ban');
                            } else {
                                _this.lineasIngreso.push({
                                    Articulo: _this.options.find(a => String(a.IdArticulo) === String(_this.articulo)).Articulo,
                                    IdArticulo: _this.articulo,
                                    Cantidad: parseFloat(_this.cantidad).toFixed(2),
                                    Precio: parseFloat(_this.precio).toFixed(2)
                                });
                                _this.acumularLineas();
                                _this.limpiar();
                            }
                        })
                        .catch(function (err) {
                            console.log(err);
                            _this.mostrarMensaje('danger', 'Error en la comunicación con el servidor.', 'ban');
                        })
                },
                borrarLinea: function (i) {
                    var _this = this;
                    $.post('/ingresos/quitar-linea/' + this.ingreso.IdIngreso, {
                        IdArticulo: this.lineasIngreso[i].IdArticulo,
                    })
                        .done(function (data) {
                            if (data.error) {
                                _this.mostrarMensaje('danger', data.error, 'ban');
                            } else {
                                _this.lineasIngreso.splice(i, 1);
                            }
                        })
                        .catch(function (err) {
                            console.log(err);
                            _this.mostrarMensaje('danger', 'Error en la comunicación con el servidor.', 'ban');
                        })
                },
                mostrarMensaje: function (tipo, mensaje, icono) {
                    var html = '<div id="mensaje" class="alert alert-' + tipo + ' alert-dismissable">'
                            + '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
                            + '<i class="fa fa-' + icono + '"></i> '
                            + '<b class="texto" >' + mensaje + '</b>'
                            + '</div>';
                    $('#errores').html(html);
                },
                goNext: function (actual) {
                    if (this.articulo && this.cantidad && this.precio) {
                        this.agregar();
                        return;
                    }
                    var next = {
                        'articulo': this.$refs.cantidad,
                        'cantidad': this.$refs.precio,
                        'precio': this.$refs.articulo
                    }
                    next[actual].focus();
                }
            }
        })
    }
}