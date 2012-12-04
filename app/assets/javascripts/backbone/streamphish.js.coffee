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
  