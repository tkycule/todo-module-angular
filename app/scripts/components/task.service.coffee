angular.module('app').factory('taskService',
  ($resource, apiHost) ->

    @resource = $resource("#{apiHost}/v1/tasks/:id/:action", {id: '@id'}, {
      update: {method: 'PUT'}
      complete: {method: 'PUT', params: {action: 'complete'}}
      revert: {method: 'PUT', params: {action: 'revert'}}
    })

    return {
      query: =>
        @tasks = @resource.query() unless @tasks
        return @tasks
        
      resource: =>
        @resource
    }
)
