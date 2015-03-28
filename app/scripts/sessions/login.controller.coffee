angular.module('app').controller('LoginController',
  ($scope, $location, authService) ->

    vm = this
    vm.submit = ->
      authService.login(vm.email, vm.password).then(
        ->
          $location.path('/tasks')
          $scope.$emit('Layout:flash', {class: 'alert-info', message: 'ログインしました。'})
        , ->
          alert authService.getError()
      )

    return
)
