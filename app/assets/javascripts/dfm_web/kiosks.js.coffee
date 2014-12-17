$(document).on 'ready page:change', ->
  $('#kiosk__destroy').change ->
    if this.checked
      $("#submit_action").hide()
      $("#destroy_action").show()
    else
      $("#submit_action").show()
      $("#destroy_action").hide()
