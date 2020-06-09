"use strict";
var Gestionx = {
    init: function () {
        new Vue({
            el: '#gestionx',
            data: {
                planes: []
            },
            created: function () {
                var _this = this;
                $.get('/api/planes')
                .done(function (planes) {
                    for (var i = 0; i < planes.length; i++) {
                        _this.planes.push(planes[i]);
                    }
                });
            }
        });
    }
};
