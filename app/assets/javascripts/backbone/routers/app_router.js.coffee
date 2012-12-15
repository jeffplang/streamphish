class Streamphish.Routers.AppRouter extends Backbone.Router

  routes:
    '':                 'index'
    'songs':            'songs'
    'songs/:title':     'song'
    'shows?year=:year': 'showsByYear'
    'shows/:date':      'showByDate'

  index: ->
    index_data = new Streamphish.Models.IndexData
    view       = new Streamphish.Views.SiteIndex( model: index_data )

    index_data.fetch
      success: (model, resp, opts) =>
        @.swap(view)

  songs: ->
    songs = new Streamphish.Collections.Songs
    view  = new Streamphish.Views.Songs( collection: songs )

    songs.fetch
      success: (model, resp, opts) =>
        @.swap(view)

  song: (title) ->
    song = new Streamphish.Models.Song( id: title )
    view = new Streamphish.Views.Song( model: song )

    song.fetch
      success: (model, resp, opts) =>
        @.swap(view)

  showsByYear: (year) ->
    shows = new Streamphish.Collections.Shows( [], {year: year} )
    view  = new Streamphish.Views.ShowsByYear( collection: shows )

    shows.fetch
      success: (model, resp, opts) =>
        @.swap(view)

  showByDate: (date) ->
    show = new Streamphish.Models.Show( id: date )
    view = new Streamphish.Views.Show( model: show )

    show.fetch
      success: (model, resp, opts) =>
        @.swap(view)

  swap: (view) ->
    @current_view.remove() if @current_view
    @current_view = view
    @current_view.render()
    $('#player')
      .before( @current_view.$el )
      .trigger('rendered')