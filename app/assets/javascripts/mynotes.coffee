handler_resize = (event) ->
  body_height = $('#app-container').height() - $('#app-header').outerHeight() - 45
  $('#app-sidebar').height body_height
  $('#app-body').height body_height

$(window).resize handler_resize

$(document).ready (event) ->
  handler_resize event
