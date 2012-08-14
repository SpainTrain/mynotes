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
