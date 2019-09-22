"use strict";

var TabsPV = {
    init: function (IdPuntoVenta) {
        new Vue({
            el: '#tabsPV',
            data: function () {
                return {
                    IdPuntoVenta: IdPuntoVenta,
                    query: ''
                };
            },
            created: function () {
                var _this = this;
                var query = location.search
                if (query) {
                    var queryObj = {};
                    query = query.replace('?', '').split('=');
                    for (var i = 0; i < query.length; i += 2) {
                        queryObj[query[i]] = query[i+1];
                    }
                    query = queryObj;
                }
                this.query = query;
                $(document).ready(function () {
                    if (!query) {
                        var Nombre = Object.keys(_this.$refs)[0];
                        _this.setTab(Nombre, true);
                    } else {
                        _this.setTab(query['tab'], true);
                    }
                });
            },
            methods: {
                setQuery: function (key, val) {
                    if (!this.query) {
                        this.query = {}
                    }
                    this.query[key] = val;
                    var search = '?';
                    var _this = this;
                    var keys = Object.keys(this.query);
                    keys.forEach(function (k, ix) {
                        search += k + '=' + _this.query[k];
                        if (ix !== keys.length - 1) {
                            search += '&';
                        }
                    })
                    location.search = search;
                },
                setTab: function (Nombre, firstLoad) {
                    if (firstLoad) {
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
                    } else {
                        this.setQuery('tab', Nombre);
                    }
                },
                setContent: function (data) {
                    var _this = this;
                    $('#tabContent').html(data);
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