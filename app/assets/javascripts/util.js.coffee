class Util
  @msToMMSS: (ms) ->
    minutes = Math.floor(ms / (1000 * 60))
    remainingMs = ms - (minutes * 1000 * 60)
    seconds = Math.round(remainingMs / 1000)

    "#{ minutes }:#{if seconds < 10 then '0' else '' }#{ seconds }"

  @clamp: (val, min, max) ->
    Math.max(min, Math.min(max, val))

SP.Util = Util