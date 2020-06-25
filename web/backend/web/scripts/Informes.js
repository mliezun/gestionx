var Informes = {
    init: function () {
        this.vueInit();

        var doubleScroll = function (element) {
            var scrollbar = document.createElement('div');
            scrollbar.appendChild(document.createElement('div'));
            scrollbar.style.overflow = 'auto';
            scrollbar.style.overflowY = 'hidden';
            scrollbar.firstChild.style.width = element.scrollWidth + 'px';
            scrollbar.firstChild.style.paddingTop = '1px';
            scrollbar.firstChild.appendChild(document.createTextNode('\xA0'));
            scrollbar.onscroll = function () {
                element.scrollLeft = scrollbar.scrollLeft;
            };
            element.onscroll = function () {
                scrollbar.scrollLeft = element.scrollLeft;
            };
            element.parentNode.insertBefore(scrollbar, element);
        }

        var elemento = document.getElementById('doublescroll');
        if (elemento)
            doubleScroll(elemento);
    },
    vueInit: function () {
        new Vue({
            el: "#informes",
            data: {
                cargando: false
            },
            methods: {
                generarInforme: function (idReporte) {
                    var _this = this;
                    _this.cargando = true;

                    // Se usa FormData porque permite también la subida de archivos
                    var datos = new FormData(_this.$refs.forminformes);

                    //Se realiza el request con los datos por POST        
                    var request = $.ajax({
                        url: '/informes/' + idReporte,
                        data: datos,
                        type: 'POST',
                        contentType: false,
                        processData: false
                    });
                    request.done(function (data) {
                        if (!data.error)
                        {
                            var key = data.key;

                            var verificarEstado = function (tiempo) {
                                setTimeout(function () {
                                    $.get('/informes/estado/' + idReporte, {'key': key}).done(function (data) {
                                        if (data.ready)
                                            window.location = '/informes/' + idReporte + '?key=' + key;
                                        else
                                            verificarEstado(tiempo < 5 ? tiempo + 1 : tiempo);
                                    });
                                }, tiempo * 1000);
                            };

                            verificarEstado(1);
                        }
                        else
                        {
                            _this.cargando = false;
                            Vue.set(_this,'error', {
                                'tipo': 'danger',
                                'texto': data.error
                            });
                        }
                    });

                    request.fail(function () {
                        _this.cargando = false;
                        Vue.set(_this,'error', {
                            'tipo': 'danger',
                            'texto': 'Ocurrió un error realizando la operación. Contacte con el administrador.'
                        });
                    });
                },
                excelPartido: function (idPartido, nombre) {
                    var _this = this;
                    _this.cargando = true;
                    //Se realiza el request con los datos por POST
                    var request = $.post('/informes/excel-partido/' + idPartido);

                    request.done(function (data) {
                        if (!data.error)
                        {
                            var key = data.key;
                            var verificarEstadoPartido = function (tiempo) {
                                setTimeout(function () {
                                    var requestEstado = $.get('/informes/estado/', {'key': key});

                                    requestEstado.done(function (data) {
                                        if (data.ready)
                                        {
                                            $.get('/informes/excel-partido/', {'key': key}).done(function (data) {
                                                var verificarEstadoTabla = function (tiempo) {
                                                    setTimeout(function () {
                                                        $.get('/informes/estado-tabla/', {'key': key}).done(function (data) {
                                                            if (data.ready)
                                                            {
                                                                _this.cargando = false;
                                                                window.location.assign('/informes/descargar?key=' + key + '&nombre=' + nombre);
                                                            }
                                                            else
                                                                verificarEstadoTabla(tiempo < 5 ? tiempo + 1 : tiempo);
                                                        })
                                                                .fail(function () {
                                                                    _this.cargando = false;
                                                                });

                                                    }, tiempo * 1000);
                                                };

                                                verificarEstadoTabla(1);
                                            })
                                                    .fail(function () {
                                                        _this.cargando = false;
                                                    });
                                        }
                                        else
                                            verificarEstadoPartido(tiempo < 5 ? tiempo + 1 : tiempo);
                                    });
                                }
                                , tiempo * 1000);
                            };

                            verificarEstadoPartido(1);
                        }
                        else
                        {
                            _this.cargando = false;

                            Vue.set(_this,'error', {
                                'tipo': 'danger',
                                'texto': data.error
                            });
                        }
                    });

                    request.fail(function () {
                        _this.cargando = false;
                        
                        Vue.set(_this,'error', {
                            'tipo': 'danger',
                            'texto': 'Ocurrió un error realizando la operación. Contacte con el administrador.'
                        });
                    });
                }
            }
        });
    }
};
