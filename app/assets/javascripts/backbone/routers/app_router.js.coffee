class Streamphish.Routers.AppRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    '':                 'index'
    'songs/:song':      'song'
    'shows?year=:year': 'showsByYear'
    'shows/:date':      'showByDate'

  index: ->
    App.models.index_data = new Streamphish.Models.IndexData
    App.views.site_index  = new Streamphish.Views.SiteIndex( model: App.models.index_data )

    App.models.index_data.fetch
      success: (model, resp, opts) ->
        App.views.site_index.render()

  song: (song) ->
    $.getJSON "/songs/#{song}", null, (resp) ->
      console.log resp

  showsByYear: (year) ->
    App.collections.shows       ?= {}
    App.collections.shows[year]  = new Streamphish.Collections.Shows( [], {year: year} )
    App.views.shows_by_year      = new Streamphish.Views.ShowsByYear( model: App.collections.shows[year] )

    App.collections.shows[year].fetch
      success: (model, resp, opts) ->
        App.views.shows_by_year.render()

  showByDate: (date) ->
