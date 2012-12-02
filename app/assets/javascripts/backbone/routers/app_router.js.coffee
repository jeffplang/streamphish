class Streamphish.Routers.AppRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    '':                 'index'
    'songs/:song':      'song'
    'shows?year=:year': 'showsByYear'
    'shows/:date':      'showByDate'

  index: ->

  song: (song) ->
    $.getJSON "/songs/#{song}", null, (resp) ->
      console.log resp

  showsByYear: (year) ->
    $.getJSON "/shows?year=#{year}", null, (resp) ->
      App.page_view.$el.html Streamphish.Templates.shows_by_year(resp)

  showByDate: (date) ->
