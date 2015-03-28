angular.module('app').directive('compareTo', -> {
  require: 'ngModel'
  scope:
    compareTo: '='
  
  link: (scope, element, attributes, ngModel) ->

    ngModel.$validators.compareTo = (modelValue) ->
      modelValue == scope.compareTo

    scope.$watch('compareTo', ->
      ngModel.$validate()
    )
})
