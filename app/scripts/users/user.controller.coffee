angular.module('app').controller('UserController',
  ($scope, $resource, $location, authService, apiHost) ->

    vm = this

    User = $resource("#{apiHost}/v1/users")

    vm.submit = ->
      angular.forEach($scope.newUserForm, (element, fieldName) ->
        return if fieldName[0] == '$'
        element.$pristine = false
        element.$dirty = true
      )

      return unless $scope.newUserForm.$valid

      user = new User({
        email: vm.email,
        password: vm.password,
        password_confirmation: vm.password_confirmation
      })

      user.$save((user, headers) ->
        authService.setUser(user)
        $location.path('/tasks')
      , (error) ->
        alert error.data.join('\n')
      )

    return
)
