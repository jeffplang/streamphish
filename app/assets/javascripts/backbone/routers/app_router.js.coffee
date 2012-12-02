class Streamphish.Routers.AppRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    '':                 'index'
    'songs/:song':      'song'
    'shows?year=:year': 'showsByYear'
    'shows/:date':      'showByDate'

  index: ->
    App.models.index_data = new Streamphish.Models.IndexData
    App.views.site_index  = new Streamphish.Views.SiteIndex(
      model: App.models.index_data
      el: $('#main')
    )

    App.models.index_data.fetch(
      success: (model, resp, opts) ->
        App.views.site_index.render()
    )

  song: (song) ->
    $.getJSON "/songs/#{song}", null, (resp) ->
      console.log resp

  showsByYear: (year) ->
    $.getJSON "/shows?year=#{year}", null, (resp) ->
      App.views.main.$el.html Streamphish.Templates.shows_by_year(resp)

  showByDate: (date) ->
