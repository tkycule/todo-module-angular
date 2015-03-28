angular.module('app').controller('LayoutController',
  ($scope, $location, $timeout, authService) ->

    vm = this
    vm.flash = null

    $scope.$on('Layout:flash', (event, flash) ->
      vm.flash = flash
    )

    $scope.$on('Layout:clearFlash', () ->
      vm.flash = null
    )

    updateCurrentUser = ->
      vm.currentUser = authService.currentUser()

    $scope.$on('authService:changeCurrentUser', updateCurrentUser)
    updateCurrentUser()

    return
)
