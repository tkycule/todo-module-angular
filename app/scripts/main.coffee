app = angular.module('app', ['ngRoute', 'ngMessages', 'ngResource', 'env'])

app.config(($routeProvider, $locationProvider) ->

  $locationProvider.html5Mode(true)

  $routeProvider
    .when('/', {
      controller: 'LoginController'
      controllerAs: "login"
      templateUrl: 'sessions/login.html'
    }).when('/users/new', {
      controller: 'UserController'
      controllerAs: "user"
      templateUrl: 'users/new.html'
    }).when('/tasks', {
      controller: 'TasksController'
      controllerAs: "tasks"
      templateUrl: 'tasks/index.html'
    }).when('/tasks/:state', {
      controller: 'TasksController'
      controllerAs: "tasks"
      templateUrl: 'tasks/index.html'
    }).when('/tasks/:id/edit', {
      controller: 'TaskEditController'
      controllerAs: "edit"
      templateUrl: 'tasks/edit.html'
    }).when('/logout', {
      controller: 'LogoutController'
      controllerAs: "logout"
      template: ''
    }).otherwise({
      redirectTo: '/'
    })
)
