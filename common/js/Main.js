var Main = {
  opciones: {
      pace: {
          ajax: {
              trackMethods: ['GET', 'POST']
          }
      },
      tooltip: {
          container: 'body',
          title: function () {
              return $(this).data('hint');
          }
      },
      confirm: {
          'title': function () {
              return $(this).data('mensaje');
          },
          'btnOkLabel': 'Aceptar',
          'btnCancelLabel': 'Cancelar',
          rootSelector: function() {
              return Main.selectores.confirm;
          },
          'singleton': true,
          'placement': 'left',
          'container': 'body'
      }
  },
  selectores: {
      tooltip: '[data-hint]',
      confirm: '[data-mensaje]', // Confirmar acción
      selectOnFocus: '[data-focus-select]', // Seleccionar el texto al hacer focus
      modal: '[data-modal]', 
      ajax: '[data-ajax]' // Request a la url indicada en este selector
  },
  init: function () {
      var _this = Main;
      window.paceOptions = _this.opciones.pace;

      // Selecciono como activa la pestaña actual
      $('.nav-tabs').find('a').each(function () {
          if ($(this).attr('href') != '/' && $(this).attr('href').indexOf(window.location.pathname) == 0)
              $(this).closest('li').addClass('active');
      });

      // Oculto los menús que no tienen nada activo en navbars dentro del content (usado en permisos)
      $('.content .navbar-nav').find('.dropdown').each(function () {
          if ($(this).find('li').length == 0)
              $(this).hide();
      });

      // Affix
      var $affixElement = $('div[data-spy="affix"]');
      $affixElement.width($affixElement.parent().width());
      $('body').on('affix.bs.affix', 'div[data-spy="affix"]', function (e) {
          var $this = $(this);
          if ($this.outerHeight() + 250 >= Math.max($(document).height(), $(document.body).height()))
          {
              e.preventDefault();
          }
      });

      _this.initAjax();
      _this.initEventos();
      _this.initInputMasks();
      // VueDirectives.init();
  },
  initEventos: function () {
      var _this = Main;

      $('body').on('pjax:complete', function () {
          _this.initAjax();
      });

      $('body').on('click', _this.selectores.selectOnFocus, function (event) {
          $(event.target).select();
      });

      $('body').on('click', _this.selectores.modal, function () {
          _this.modal($(this).data('modal'));
      });

      // Hacer request con ajax en los elementos con data-ajax=url. Evita recarga y muestra mensaje de éxito si hay data-success
      $('body').on('click', _this.selectores.ajax, function (e) {
          _this.ajax(this);
      });

      // Reemplazar el % por %%%% en select2
      $('body').on('keyup', '.select2-search__field', function (e) {
          var $this = $(this);
          if ($this.val() == '%' && e.which == 53)
          {
              $this.val('%%%%');
              $this.trigger('input');
          }
      });

  },
  initAjax: function () {
      var _this = Main;
      $('.tooltip').remove();

      $(_this.selectores.tooltip).tooltip(_this.opciones.tooltip);

      // Mensaje pidiendo confirmación en las acciones con data-mensaje
      $(_this.selectores.confirm).confirmation(_this.opciones.confirm);

      // Configuración por defecto de Select2
      if ($.fn.select2)
          $.fn.select2.defaults.set("selectOnClose", true);

      //Sortable.init();
  },
  initInputMasks: function () {
      Inputmask.extendAliases({
          'moneda': {
              alias: 'numeric',
              groupSeparator: ',',
              autoGroup: '!0',
              digits: 2,
              radixPoint: ',',
              autoUnmask: true,
              unmaskAsNumber: true,
              removeMaskOnSubmit: true,
              onBeforeMask: function (value) {
                  var processedValue = value.replace(/\./g, ",");
                  return processedValue;
              }
          }
      });
  },
  modal: function (url) {
      var _this = Main;

      // Si hay un modal abierto no abro otro
      if ($('.modal').length > 0)
          return;

      var html = '<div class="modal fade"></div>';

      $(html).modal({
          backdrop: 'static',
          keyboard: false})
              .on('hidden.bs.modal', function () {
                  $(this).remove();
              })
              .load(url, function () {
                  var $modal = $(this);
                  var $form = $(this).find('form');

                  setTimeout(function () {
                      $('.modal').trigger('shown.bs.modal');

                      // Obtengo el primer input no oculto
                      var $primerInput = $form.find('input:not([type=hidden]),select').filter(':first');

                      // Hago focus si es type=text o select y no es un datepicker
                      if ($primerInput.hasClass('select2-hidden-accessible'))
                          $primerInput.select2('open');
                      else if (($primerInput.attr('type') == 'text' || $primerInput.is('select')) &&
                              // es datepicker
                              !$primerInput.hasClass('datepicker-to') && !$primerInput.hasClass('datepicker-from') && !$primerInput.parent().hasClass('date'))
                          $primerInput.focus();

                      _this.initAjax();

                  }, 500);
                  $modal.on('beforeSubmit', 'form', function (e) {
                      _this.submitModal(this);
                      e.preventDefault();
                      e.stopPropagation();
                      e.stopImmediatePropagation();
                      return false;
                  });
              });
  },
  // Evento ejecutado para hacer submit de formularios con ajax
  submitModal: function (form) {
      var $form = $(form);

      // Se usa FormData porque permite también la subida de archivos
      var datos = Main.obtenerFormData(form);

      //Desactivo el botón de submit, para que el usuario no realice clicks 
      //repetidos hasta que se reciba la respuesta del servidor.
      $form.closest('.modal-content').find('[data-dismiss=modal]').attr('disabled', true);
      $form.find(':submit').attr('disabled', true);

      //Se realiza el request con los datos por POST        
      $.ajax({
          url: $form.attr("action"),
          data: datos,
          type: 'POST',
          contentType: false,
          processData: false, })
              .done(function (data) {
                  if (data.error)
                  {
                      var evento = jQuery.Event("error.modalform");
                      $('.modal').trigger(evento, [data]);

                      if (!evento.isDefaultPrevented())
                      {
                          mensaje = data.error;
                          tipo = 'danger';
                          //Agregando mensaje de error al diálogo modal
                          var html = '<div id="mensaje-modal" class="alert alert-' + tipo + ' alert-dismissable">'
                                  + '<i class="fa fa-ban"></i> '
                                  + '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
                                  + '<b class="texto" >' + mensaje + '</b>'
                                  + '</div>';
                          $('#errores-modal').html(html);
                      }

                      //Se activa nuevamente el botón
                      $form.closest('.modal-content').find('[data-dismiss=modal]').attr('disabled', false);
                      $form.find(':submit').attr('disabled', false);
                  }
                  else
                  {
                      var evento = jQuery.Event("success.modalform");
                      $('.modal').trigger(evento, [data]);

                      if (!evento.isDefaultPrevented())
                      {
                          if ($form.closest(".modal-dialog").data('no-reload') === undefined)
                              location.reload();
                          else
                              $('.modal').modal('hide');
                      }
                      else
                      {
                          //Se activa nuevamente el botón
                          $form.closest('.modal-content').find('[data-dismiss=modal]').attr('disabled', false);
                          $form.find(':submit').attr('disabled', false);
                      }
                  }
              })
              .fail(function (data) {
                  if (data.status !== 302)
                  {
                      var evento = jQuery.Event("error.modalform");
                      $('.modal').trigger(evento);

                      if (!evento.isDefaultPrevented())
                      {
                          var tipo = 'danger';
                          var mensaje = 'Error en la comunicación con el servidor. Contacte con el administrador.';
                          //Agregando mensaje de error al diálogo modal
                          var html = '<div id="mensaje-modal" class="alert alert-' + tipo + ' alert-dismissable">'
                                  + '<i class="fa fa-ban"></i> '
                                  + '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
                                  + '<b class="texto" >' + mensaje + '</b>'
                                  + '</div>';
                          $('#errores-modal').html(html);
                          //Se activa nuevamente el botón
                          $form.closest('.modal-content').find('[data-dismiss=modal]').attr('disabled', false);
                          $form.find(':submit').attr('disabled', false);
                      }
                  }
              });
  },
  modalClose: function () {
      $('.modal').remove();
      $('.modal-backdrop').remove();
  },
  // Hacer request con ajax en los elementos con data-ajax=url. Evita recarga y muestra mensaje de éxito si hay data-success
  ajax: function (elemento) {
      var url = $(elemento).data('ajax');
      var success = $(elemento).data('success');

      $.get(url)
              .done(function (data) {
                  if (data.error)
                  {
                      var evento = jQuery.Event("error.ajax");
                      $(elemento).trigger(evento, [data]);

                      if (!evento.isDefaultPrevented())
                      {
                          var tipo = 'danger';
                          var mensaje = data.error;
                          var icono = 'ban';
                          //Agregando mensaje de error al diálogo modal
                          var html = '<div id="mensaje-modal" class="alert alert-' + tipo + ' alert-dismissable">'
                                  + '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
                                  + '<i class="fa fa-' + icono + '"></i> '
                                  + '<b class="texto" >' + mensaje + '</b>'
                                  + '</div>';
                          $('#errores').html(html);
                      }
                  }
                  else
                  {
                      if (success)
                      {
                          var tipo = 'success';
                          var mensaje = success;
                          var icono = 'check';
                          //Agregando mensaje de error al diálogo modal
                          var html = '<div id="mensaje-modal" class="alert alert-' + tipo + ' alert-dismissable">'
                                  + '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
                                  + '<i class="fa fa-' + icono + '"></i> '
                                  + '<b class="texto" >' + mensaje + '</b>'
                                  + '</div>';
                          $('#errores').html(html);
                      }
                      else
                      {
                          var evento = jQuery.Event("success.ajax");
                          $(elemento).trigger(evento, [data]);

                          if (!evento.isDefaultPrevented())
                          {
                              if ($.support.pjax)
                              {
                                  window.location.hash = '';
                                  $.pjax.reload('#pjax-container');
                              }
                              else
                                  location.reload();
                          }
                      }
                  }
              })
              .fail(function () {
                  var tipo = 'danger';
                  var mensaje = 'Error en la comunicación con el servidor. Contacte con el administrador.';
                  var icono = 'ban';
                  //Agregando mensaje de error al diálogo modal
                  var html = '<div id="mensaje-modal" class="alert alert-' + tipo + ' alert-dismissable">'
                          + '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>'
                          + '<i class="fa fa-' + icono + '"></i> '
                          + '<b class="texto" >' + mensaje + '</b>'
                          + '</div>';
                  $('#errores').html(html);
              });
  },

  /**
   * Retorna un FormData del form. Contempla el input mask
   * 
   * @param {type} form
   * @returns {FormData}
   */
  obtenerFormData: function (form) {
      var $form = $(form);
      var inputs = $form.find('input');

      var maskOptions = Main._obtenerOpcionesMask(inputs);

      inputs.inputmask('remove');

      var datos = new FormData(form);

      Main._restaurarMask(inputs, maskOptions);

      return datos;
  },

  imprimir: function () {
      var colapsado = $("body").hasClass('sidebar-collapse');

      if (!colapsado)
          $("body").addClass('sidebar-collapse');

      window.print();

      if (!colapsado)
          $("body").removeClass('sidebar-collapse');
  },

  _obtenerOpcionesMask: function (inputs) {
      var maskOptions = {};

      for (var i = 0; i < inputs.length; i++) {
          if (inputs[i].inputmask)
          {
              maskOptions[i] = inputs[i].inputmask.userOptions;
          }
      }

      return maskOptions;
  },

  _restaurarMask: function (inputs, maskOptions) {
      for (var i = 0; i < inputs.length; i++) {
          if (maskOptions[i])
              $(inputs[i]).inputmask(maskOptions[i]);
      }
  }
};
