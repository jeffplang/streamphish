class Streamphish.Routers.AppRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    '':                 'index'
    'songs':            'songs'         
    'songs/:title':     'song'
    'shows?year=:year': 'showsByYear'
    'shows/:date':      'showByDate'

  index: ->
    App.models.index_data = new Streamphish.Models.IndexData
    App.current_view  = new Streamphish.Views.SiteIndex( model: App.models.index_data )

    App.models.index_data.fetch
      success: (model, resp, opts) ->
        App.current_view.render()

  songs: ->
    App.collections.songs = new Streamphish.Collections.Songs
    App.current_view       = new Streamphish.Views.Songs( model: App.collections.songs )

    App.collections.songs.fetch
      success: (model, resp, opts) ->
        App.current_view.render()

  song: (title) ->
    App.models.song = new Streamphish.Models.Song( id: title )
    App.current_view  = new Streamphish.Views.Song( model: App.models.song )

    App.models.song.fetch
      success: (model, resp, opts) ->
        App.current_view.render()

  showsByYear: (year) ->
    App.collections.shows       ?= {}
    App.collections.shows[year]  = new Streamphish.Collections.Shows( [], {year: year} )
    App.current_view      = new Streamphish.Views.ShowsByYear( model: App.collections.shows[year] )

    App.collections.shows[year].fetch
      success: (model, resp, opts) ->
        App.current_view.render()

  showByDate: (date) ->
    App.models.show = new Streamphish.Models.Show( id: date )
    App.current_view  = new Streamphish.Views.Show( model: App.models.show )

    App.models.show.fetch
      success: (model, resp, opts) ->
        App.current_view.render()