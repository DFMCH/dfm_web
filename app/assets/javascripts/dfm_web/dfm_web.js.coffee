# DFM Web Common Javascript


$(document).on 'ready page:load', ->

  # Activate Tablesorter (add to table)
  $('.tablesorter').tablesorter({widgets: ['zebra']})

  # Hide the flash[:notice] after 5 seconds
  $('#notice').delay(5000).slideUp('slow')

  # Load anything you want with ajax easily.  Add ajax_load class to a div and set path html5 data attrib.
  $(".ajax_load").each ->
    $(this).load( $(this).data('path') )

  # Activate DatePicker (add to text_field)
  $('.datepicker').datepicker dateFormat: "yy-mm-dd"