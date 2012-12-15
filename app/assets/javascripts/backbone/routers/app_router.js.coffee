class Streamphish.Routers.AppRouter extends Backbone.Router

  routes:
    '':                 'index'
    'songs':            'songs'
    'songs/:title':     'song'
    'shows?year=:year': 'showsByYear'
    'shows/:date':      'showByDate'

  index: ->
    indexData = new Streamphish.Models.IndexData
    view      = new Streamphish.Views.SiteIndex( model: indexData )

    indexData.fetch
      success: (model, resp, opts) =>
        @swap(view)

  songs: ->
    songs = new Streamphish.Collections.Songs
    view  = new Streamphish.Views.Songs( collection: songs )

    songs.fetch
      success: (model, resp, opts) =>
        @swap(view)

  song: (title) ->
    song = new Streamphish.Models.Song( id: title )
    view = new Streamphish.Views.Song( model: song )

    song.fetch
      success: (model, resp, opts) =>
        @swap(view)

  showsByYear: (year) ->
    shows = new Streamphish.Collections.Shows( [], year: year )
    view  = new Streamphish.Views.ShowsByYear( collection: shows )

    shows.fetch
      success: (model, resp, opts) =>
        @swap(view)

  showByDate: (date) ->
    show = new Streamphish.Models.Show( id: date )
    view = new Streamphish.Views.Show( model: show )

    show.fetch
      success: (model, resp, opts) =>
        @swap(view)

  swap: (view) ->
    @currentView.remove() if @currentView
    @currentView = view
    @currentView.render()
    $('#player')
      .before( @currentView.$el )
      .trigger('rendered')