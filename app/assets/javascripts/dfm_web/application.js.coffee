#= require jquery
#= require jquery_ujs
#= require jquery.ui.all
#= require cocoon
#= require highcharts/highcharts
#= require_tree .





# I want to detect anchor tags in the /answer_sets area
$(window).on 'ready hashchange', ->
  if ( location.hash.indexOf("#date") >= 0 )
    $(".date-all").hide()
    $("." + location.hash.substring(1) ).show()