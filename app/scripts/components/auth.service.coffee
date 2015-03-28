angular.module('app').factory('authService',
  ($http, $q, $resource, $rootScope, apiHost) ->

    user = null
    error = null
    Session = $resource("#{apiHost}/v1/sessions")

    setUser = (_user) ->
      if _user?
        user = _user
        localStorage.user = angular.toJson(user)
        $http.defaults.headers.common['Authorization'] = user.authentication_token
        $rootScope.$broadcast('authService:changeCurrentUser')

    setUser(angular.fromJson(localStorage.user))

    return {
      currentUser: -> user

      login: (email, password) ->

        deferred = $q.defer()

        session = new Session(email: email, password: password)
        session.$save((user, headers) =>
          @setUser(user)
          deferred.resolve()
        , ->
          error = 'ログインに失敗しました'
          deferred.reject()
        )

        return deferred.promise

      logout: ->
        user = null
        localStorage.removeItem('user')
        $http.defaults.headers.common['Authorization'] = null
        $rootScope.$broadcast('authService:changeCurrentUser')

      getError: -> error

      setUser: setUser
    }
)

