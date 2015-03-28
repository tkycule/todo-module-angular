angular.module('app').controller('LogoutController',
  ($scope, $location, authService) ->

    authService.logout()
    $location.path('/')

    $scope.$emit('Layout:flash', {class: 'alert-info', message: 'ログアウトしました。'})

    return
)
