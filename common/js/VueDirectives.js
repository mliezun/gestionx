/* global Vue */

'use strict';

var VueDirectives = {
    init: function () {
        /*
         * Directiva para permitir la inicialización del model con el atributo val del input.
         * El modelo debe estar definido en el data.
         * 
         * Uso: <input type="text" v-model="modelo" val="valor" v-init>
         */
        this.vinit();
        /*
         * Permite vincular un select2 a un modelo. Vincula valor inicial obtenido del atributo value.
         * 
         * Uso: v-select2="model"
         */
        this.select2();
        /*
         * Directiva para aplicar una máscara al input usando jquery-inputmask.
         * 
         * Uso: <input type="text" v-model="modelo" v-inputmask="{'alias':'moneda'}">
         */
        this.inputmask();
        /*
         * Permite actualizar el model desde un datepicker. Se debe usar junto al widget de datepicker de Yii.
         * *
         * Uso: <input type="text" v-datepicker="fecha">
         */
        this.datepicker();
        /*
         * Previene el doble submit al utilizar ActiveForm con @submit.
         * *
         * Uso: 
         * $form = ActiveForm::begin([
         *       'id' => 'id-form',
         *       'options' => [
         *           'v-on:submit.stop.prevent' => 'onSubmit',
         *           'v-prevent-yii-submit' => true
         *       ]
         *   ]);
         * 
         */
        this.formPreventSubmit();
    },
    vinit: function () {
        var _this = this;
        Vue.directive('init', {
            bind: function (el, binding, vnode) {
                var directivasModel = vnode.data.directives.filter(function (objeto) {
                    return objeto.name == 'model';
                });

                var valor = $(el).val() ? $(el).val() : $(el).attr('value');

                if (!valor && $(el).is('textarea'))
                    valor = $(el).text();

                if (directivasModel.length > 0 && valor)
                {
                    var model = directivasModel[0].expression;
                    var objeto = vnode.context;

                    _this.setearModel(objeto, model, valor);
                }
            }
        });
    },
    select2: function () {
        var _this = this;
        Vue.directive('select2', {
            bind: function (el, binding, vnode) {
                var vm = vnode.context;
                var $el = $(el);

                // Obtengo los datos que se pasan como parámetro a Vue.set
                var objetoSet = vnode.context;
                var model = binding.expression;

                _this.setearModel(objetoSet, model, $el.val());

                // Escucho el cambio en el select2 y actualizo el modelo
                $el.select2().on('change', function () {
                    _this.setearModel(objetoSet, model, this.value);
                });

                // Cuando cambia el modelo, actualizo el select2
                vm.$watch(model, function (valor) {
                    // Si el valor del select2 es el mismo que el del model no es necesario hacer nada
                    if ($el.val() == valor)
                        return;
                    if (valor && valor != 0 && valor != '')
                    {
                        // Si había una función de initSelection vinculada al componente se la ejecuta con el nuevo valor
                        if (window[$el.data('krajee-select2')].initSelection)
                        {
                            $el.append('<option value=' + valor + '></option>');
                            $el.val(valor);
                            // Obtengo la función de initSelection de los datos de inicialización del componente
                            var initSelection = window[$el.data('krajee-select2')].initSelection;
                            initSelection($el, function (data) {
                                $el.html('<option value=' + data.id + '>' + data.text + '</option>');
                                $el.val(data.id).trigger('change');
                            });
                        }
                        else
                            $(el).val(vm[model]).trigger('change');
                    }
                    else
                        $(el).val("").trigger('change');
                });
            },
            unbind: function (el) {
                $(el).off().select2('destroy');
            }
        });
    },
    inputmask: function () {
        var _this = this;
        Vue.directive('inputmask', {
            bind: function (el, binding, vnode) {
                var $el = $(el);

                // Inicializo el componente 
                Vue.nextTick(function () {
                    $el.inputmask(binding.value);
                });

                // Asigno al valor al model cuando se presione alguna tecla en el input
                $el.on('keyup', function () {
                    // Obtengo los datos que se pasan como parámetro a Vue.set
                    var objetoSet = vnode.context;
                    var model = vnode.data.directives.filter(function (objeto) {
                        return objeto.name == 'model'
                    })[0].expression;

                    _this.setearModel(objetoSet, model, $el.val());
                });
            }
        });

    },
    formPreventSubmit: function () {
        Vue.directive('prevent-yii-submit', {
            bind: function (el) {
                var $el = $(el);
                $el.on('beforeSubmit', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    e.stopImmediatePropagation();
                    return false;
                });
            }
        });
    },
    datepicker: function () {
        var _this = this;
        Vue.directive('datepicker', {
            bind: function (el, binding, vnode) {
                var $el = $(el);
                var model = binding.expression;

                // Asigno al valor al model cuando se presione alguna tecla en el input
                $el.on('change', function () {
                    // Obtengo los datos que se pasan como parámetro a Vue.set
                    var objetoSet = vnode.context;

                    _this.setearModel(objetoSet, model, $el.val());
                });
            }
        });
    },
    setearModel: function (objeto, model, valor) {
        // Considero los campos que están asociados a un atributo de un objeto dentro del $data
        // Ej: AutorizaForm.Motivo
        if (model.split('.').length > 1)
        {
            var atributos = model.split('.');
            model = atributos[atributos.length - 1];

            for (var i = 0; i < atributos.length - 1; i++)
            {
                // Verifico si el atributo es un elemento en un array
                var atributo = atributos[i].split('[');
                if (atributo.length > 1)
                {
                    var indice = atributo[1].replace(']', '');
                    objeto = objeto[atributo[0]][indice];
                }
                else
                    objeto = objeto[atributo[0]];
            }
        }

        Vue.set(objeto, model, valor);
    }
};