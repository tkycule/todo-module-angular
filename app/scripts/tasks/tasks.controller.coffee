angular.module('app').controller('TasksController',
  ($scope, $resource, $http, $routeParams, $location, $filter, taskService) ->

    vm = this

    vm.state = $routeParams.state || 'inbox'

    vm.task_count = {}
    vm.tasks = taskService.query()

    vm.submit = ->
      if vm.new_task_title?.trim()
        Task = taskService.resource()
        task = new Task({title: vm.new_task_title})
        task.$save( ->
          vm.tasks.push(task)
          $scope.$emit('Layout:flash', {class: 'alert-info', message: '作成しました。'})
        )
        vm.new_task_title = ''

    vm.done = (task) ->
      task.$complete(->
        $scope.$emit('Layout:flash', {class: 'alert-info', message: '完了にしました。'})
      )

    vm.delete = (task) ->
      task.$delete(->
        $scope.$emit('Layout:flash', {class: 'alert-info', message: 'ゴミ箱に入れました。'})
      )

    vm.revert = (task) ->
      task.$revert(->
        $scope.$emit('Layout:flash', {class: 'alert-info', message: '収集箱に戻しました。'})
      )

    $scope.$watch('tasks', ->
      angular.forEach(['inbox', 'completed', 'deleted'], (state) ->
        vm.task_count[state] = $filter('filter')(vm.tasks, {aasm_state: state}).length
      )
    , true)

    $(window).bind('hashchange', ->
      vm.state = $location.hash() || 'inbox'
    )

    return
)
