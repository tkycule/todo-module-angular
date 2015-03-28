angular.module('app').controller('TaskEditController',
  ($scope, $location, $routeParams, taskService) ->

    vm = this

    taskService.query().$promise.then((tasks) ->
      $.each(tasks, (index, task) ->
        if task.id == parseInt($routeParams.id)
          vm.task = task
          return false
      )
    )

    vm.submit = ->

      return unless $scope.taskForm.$valid
      
      vm.task.$update( ->
        $location.path('/tasks')
        $scope.$emit('Layout:flash', {class: 'alert-info', message: '更新しました。'})
      )

    return
)
