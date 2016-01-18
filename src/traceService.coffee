angular.module('angularStacktrace', [])

angular.module('angularStacktrace').provider('stacktrace', ->
  @options = {
    type: 'POST'
    url: null,
    contentType: 'application/json',
  }

  @setUrl = (url) =>
    @options.url = url
    return @

  @setType = (type) =>
    @options.type = type
    return @

  @setUuid = (uuid) =>
    @options.uuid = uuid
    return @

  @$get = ->
    {
      getOption: (key) =>
        @options[key]
    }
  return
)
.provider('$exceptionHandler', ->
  @$get = (errorLogService) ->
    errorLogService
  return
)
.factory('traceService', ->
  {
    print: printStackTrace
  }
)
.factory('errorLogService', ($log, $window, stacktrace, traceService) ->
  (exception, cause) ->
    $log.error.apply($log, arguments)

    try
      errorMessage = exception.toString()
      stackTrace = traceService.print({e: exception})

      url = stacktrace.getOption('url')
      unless url then throw new Error('Cannot send exception report, please set url.')

      $.ajax({
        type: stacktrace.getOption('type'),
        url: stacktrace.getOption('url'),
        contentType: "application/json",
        data: angular.toJson({
          message: errorMessage,
          stacktrace: stackTrace,
          userAgent: $window.navigator.userAgent,
          url: $window.location.href,
          registrationUuid: stacktrace.getOption('uuid'),
        })
      })

    catch e
      $log.error e
)