#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Streamphish =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  Templates: {}
  Helpers:
    dateString: (date, fmt) ->
      # Assumes date comes in the form '1993-4-16'
      # Assumes fmt contains a '%m', '%d', and '%Y'
      date_s = date.split '-'
      d      = new Date(date_s[0], date_s[1] - 1, date_s[2])

      month  = "0#{d.getMonth() + 1}".slice -2
      day    = "0#{d.getDate()}".slice -2
      year   = d.getFullYear()

      fmt.replace('%m', month).replace('%d', day).replace('%Y', year)

    msToMMSS: (ms) ->
      minutes = Math.floor(ms / (1000 * 60))
      remainingMs = ms - (minutes * 1000 * 60)
      seconds = Math.floor(remainingMs / 1000)

      "#{ minutes }:#{if seconds < 10 then '0' else '' }#{ seconds }"

    clamp: (val, min, max) ->
      Math.max(min, Math.min(max, val))

    linkTo: (text, url) ->
      if Backbone.history._wantsPushState
        "<a href='/#{url}'>#{text}</a>"
      else
        "<a href='##{url}'>#{text}</a>"