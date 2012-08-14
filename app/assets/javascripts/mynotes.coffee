handler_resize = (event) ->
  padding_top = parseInt($("#app-container").css("padding-top").slice(0,-2))
  body_height = $('#app-container').height() - $('#app-header').outerHeight() - (45 - padding_top)
  $('#app-sidebar').height body_height
  $('#app-body').height body_height
  $("#edit-ctrl > .note-body").height($("#edit-ctrl").height() - $("#edit-ctrl > .navbar").height() - 60)

$(window).resize handler_resize

$(document).ready (event) ->
  handler_resize event
