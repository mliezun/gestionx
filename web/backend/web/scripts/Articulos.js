"use strict";
var Articulos = {
  init: function () {
    $("#tabla-articulos").stickyTableHeaders({
      fixedOffset: $(".navbar.navbar-expand-lg.bg-white.fixed-top"),
    });
  },
};
