goog.require 'goog.dom'
goog.require 'goog.editor.Command'
goog.require 'goog.editor.Field'
goog.require 'goog.editor.plugins.BasicTextFormatter'
goog.require 'goog.editor.plugins.EnterHandler'
goog.require 'goog.editor.plugins.HeaderFormatter'
goog.require 'goog.editor.plugins.LinkBubble'
goog.require 'goog.editor.plugins.LinkDialogPlugin'
goog.require 'goog.editor.plugins.ListTabHandler'
goog.require 'goog.editor.plugins.LoremIpsum'
goog.require 'goog.editor.plugins.RemoveFormatting'
goog.require 'goog.editor.plugins.SpacesTabHandler'
goog.require 'goog.editor.plugins.UndoRedo'
goog.require 'goog.ui.editor.DefaultToolbar'
goog.require 'goog.ui.editor.ToolbarController'

#Want a full screen app, so resize certain elements
handler_resize = (event) ->
  padding_top = parseInt($("#app-container").css("padding-top").slice(0,-2))
  body_height = $('#app-container').height() - $('#app-header').outerHeight() - (45 - padding_top)
  $('#app-sidebar').height body_height
  $('#app-body').height body_height
  $(".content-wrapper > .note-body").height($(".content-wrapper").height() - $(".content-wrapper > .navbar").height() - 20)
  $("#note-editor").height($("#note-editor").parent().height() - $("#note-editor").prev().height())
  return @

#init editor creates the editor iframe and attaches events
init_editor = () ->
  #Don't run on non-editing pages
  if jQuery('#note-editor').length is 0 then return @
  
  #init
  note_editor = new goog.editor.Field 'note-editor'
  
  #plugins
  note_editor.registerPlugin new goog.editor.plugins.BasicTextFormatter()
  note_editor.registerPlugin new goog.editor.plugins.RemoveFormatting()
  note_editor.registerPlugin new goog.editor.plugins.UndoRedo()
  note_editor.registerPlugin new goog.editor.plugins.ListTabHandler()
  note_editor.registerPlugin new goog.editor.plugins.SpacesTabHandler()
  note_editor.registerPlugin new goog.editor.plugins.EnterHandler()
  note_editor.registerPlugin new goog.editor.plugins.HeaderFormatter()
  note_editor.registerPlugin new goog.editor.plugins.LoremIpsum('Click here to edit')
  note_editor.registerPlugin new goog.editor.plugins.LinkDialogPlugin()
  note_editor.registerPlugin new goog.editor.plugins.LinkBubble()

  #manually wire up toolbar (using bootstrap rather than closure css)
  $("#tb-undo").click (event) ->
    note_editor.execCommand goog.editor.Command.UNDO
    note_editor.focus()
    return false

  $("#tb-redo").click (event) ->
    note_editor.execCommand goog.editor.Command.REDO
    note_editor.focus()
    return false

  $("#tb-bold").click (event) ->
    note_editor.execCommand goog.editor.Command.BOLD
    note_editor.focus()
    return false

  $("#tb-italic").click (event) ->
    note_editor.execCommand goog.editor.Command.ITALIC
    note_editor.focus()
    return false

  $("#il-submit").click (event) ->
    title = $("#il-title").val()
    url = $("#il-url").val()
    url = if url.slice 0, 7 == "http://" then url else "http://#{url}"
    content = note_editor.getInjectableContents "<a href=\"#{ url }\">#{ title }</a>"
    note_editor.focus()
    $(note_editor.getElement()).append content
    note_editor.focus()
    $("#il-title").val("")
    $("#il-url").val("")
    $("#new_note_body").val(note_editor.getCleanContents()).change()
    return true

  #Listen for toolbar-related events
  ### not currently working
  goog.events.listen note_editor, goog.editor.Field.EventType.COMMAND_VALUE_CHANGE, () ->
    if not @.dispatchEvent goog.ui.Component.EventType.CHANGE
      return @
    note_editor.dispatchEvent(goog.editor.Field.EventType.FOCUS)
    console.log arguments, note_editor.queryCommandValue('BOLD')
    return @
  ###

  #watch for changes to content
  goog.events.listen note_editor, goog.editor.Field.EventType.DELAYEDCHANGE, () ->
    $("#new_note_body").val(note_editor.getCleanContents()).change()
    return @
  
  note_editor.setHtml false, $("#note_body").val()
  note_editor.makeEditable()
  return @

$(window).resize handler_resize

$(document).ready (event) ->
  handler_resize event
  init_editor()
  if (html_str = $("#note_body").val())?
    $("#show-body").html html_str
  console.log "Everything loaded", event
  return @
