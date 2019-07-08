"use strict";

var TabsPV = {
    init: function (IdPuntoVenta) {
        new Vue({
            el: '#tabsPV',
            data: function () {
                return {
                    IdPuntoVenta: IdPuntoVenta
                };
            },
            created: function () {
                var _this = this;
                $(document).ready(function () {
                    var Nombre = Object.keys(_this.$refs)[0];
                    _this.setTab(Nombre);
                });
            },
            methods: {
                setTab: function (Nombre) {
                    var _this = this;
                    document.getElementById('tabContent').innerHTML = '';
                    Object.keys(_this.$refs).forEach(r => {
                        _this.$refs[r].classList.remove('active');
                    });
                    _this.$refs[Nombre].classList.add('active');
                    $.ajax('/puntos-venta/tab-content/' + _this.IdPuntoVenta + '?Nombre=' + Nombre)
                        .done(function (data) {
                            _this.setContent(data);
                        });
                },
                setContent: function (data) {
                    var _this = this;
                    document.getElementById('tabContent').innerHTML = data;
                    $('form').submit(function (e) {
                        _this.submitBuscar(this);
                        e.preventDefault();
                        e.stopPropagation();
                        e.stopImmediatePropagation();
                        return false;
                    })
                },
                submitBuscar: function (form) {
                    var _this = this;
                    var $form = $(form);
                    var datos = Main.obtenerFormData(form);
                    $.ajax({
                        url: $form.attr("action"),
                        data: datos,
                        type: 'POST',
                        contentType: false,
                        processData: false
                    })
                        .done(function (data) {
                            _this.setContent(data);
                        });
                }
            }
        });
    }
};