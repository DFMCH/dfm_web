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
//= require dfm_web/dfm_web
//= require_self

// See dfm_web/dfm_web.js for information
document.addEventListener("DOMContentLoaded",function() {
    DfmWeb.activate_dfm_web();
    document.getElementById("window_width").innerHTML = window.innerWidth;
})

window.addEventListener("resize", function() {
    document.getElementById("window_width").innerHTML = window.innerWidth;
});
