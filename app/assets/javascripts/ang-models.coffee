@NotesCtrl = ($scope, $http) ->
  #init scope vars
  $scope.index_url = $("#index-url").val()
  $scope.refreshing = false
  
  #get id from the url IF it exists
  url_id = location.pathname.match(/[a-fA-F0-9]{31}/)?[0]

  #function to refresh the list via index action
  $scope.refreshNotes = ->
    $scope.refreshing = true
    $http.get($scope.index_url)
      .success (data) ->
        $scope.notes = []
        if data is "null" then return @
        for own key, val of data
          val['id'] = key
          val['state'] = if key == url_id then 'active' else ''
          #val['href'] = if key == url_id then '#' else "#{$scope.index_url}/#{key}"
          val['href'] = val['url']
          $scope.notes.push val
        $scope.error = $scope.refreshing = false
        return @
      .error (data, status, headers, config) ->
        $scope.notes = []
        $scope.error = true
        $scope.refreshing = false
        console?.error data, status, config
    return @

  $scope.refreshNotes()
  return @

#inject annotation so that minifiers don't kill the DI
@NotesCtrl.$inject = ['$scope', '$http']

@EditNote = ($scope, $http) ->
  self = @

  #init icons to dark
  $scope.clean_class = ''

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
      is_clean = angular.equals $scope.note, self.original
      $scope.clean_class = if not is_clean then '' else 'icon-white'
      return is_clean

  $scope.reset = (opt_prop_name) ->
    if opt_prop_name?
      $scope.note[opt_prop_name] = self.original[opt_prop_name]
    else
      $scope.note = angular.copy self.original
    $scope.update()
    return @

  $scope.update = () ->
    promise = $http.put $scope.note.url, $scope.note
    promise.success (data, status, headers, config) ->
      $scope.note = data
      self.original = angular.copy $scope.note
      return @
    #TODO: promise.error () ->
    return @

  #hack because ng-model doesn't seem to work on hidden inputs
  jQuery("#new_note_body").change (event) ->
    $scope.note.body = jQuery(this).val()
    $scope.$digest()
    return @



  return @

#inject annotation so that minifiers don't kill the DI
@EditNote.$inject = ['$scope', '$http']
