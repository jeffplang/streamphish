class Streamphish.Util
  @msToMMSS: (ms) ->
    minutes = Math.floor(ms / (1000 * 60))
    remainingMs = ms - (minutes * 1000 * 60)
    seconds = Math.floor(remainingMs / 1000)

    "#{ minutes }:#{if seconds < 10 then '0' else '' }#{ seconds }"

  @clamp: (val, min, max) ->
    Math.max(min, Math.min(max, val))

  @isFirefox: ->
    navigator.userAgent.toLowerCase().indexOf('firefox') > -1
