@NotesCtrl = ($scope, $http) ->
  $scope.refreshNotes = ->
    $scope.refreshing = true
    $http.get('/notes').success (data) ->
      $scope.note_count = 0
      $scope.notes = data
      for own key, val of $scope.notes
        val['id'] = key
        $scope.note_count++
      $scope.refreshing = false
      return @
    return @
  $scope.refreshing = false
  $scope.refreshNotes()
  return @

@EditNote = ($scope, $http) ->
  self = @

  #Init the model from hidden inputs
  $scope.note =
    title: jQuery("#note_title").val()
    body: jQuery("#note_body").val()
    url: jQuery("#note_url").val()
    last_saved: jQuery("#note_last_saved").val()

  #store original for comparing/reverting
  self.original = angular.copy $scope.note

  #setup CSRF protection
  csrf_token = jQuery("meta[name='csrf-token']").attr "content"
  $http.defaults.headers.put['X-CSRF-Token'] = csrf_token
  $http.defaults.headers.put['X-XSRF-TOKEN'] = csrf_token

  $scope.isClean = (opt_prop_name) ->
    if opt_prop_name?
      return angular.equals $scope.note[opt_prop_name], self.original[opt_prop_name]
    else
      return angular.equals $scope.note, self.original

  $scope.reset = (opt_prop_name) ->
    if opt_prop_name?
      $scope.note[opt_prop_name] = self.original[opt_prop_name]
    else
      $scope.note = angular.copy self.original
    return @

  $scope.update = () ->
    promise = $http.put $scope.note.url, $scope.note
    promise.success (data, status, headers, config) ->
      console.log data, status, headers, config
    return @

  return @
