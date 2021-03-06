// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery2
//= require jquery_ujs
//= require jquery-tablesorter
//= require dfm_web/dfm_web
//= require_self

// See dfm_web/dfm_web.js.coffee for information
$(document).on('ready page:load', function() {
    DfmWeb.activate_dfm_web();
    $("#window_width").html(window.innerWidth);
    window.addEventListener('resize', () => {$("#window_width").html(window.innerWidth);} );
    $('.tablesorter').tablesorter({widgets: ['zebra']})
});
