class Streamphish.Routers.AppRouter extends Backbone.Router

  routes:
    '':                 'index'
    'songs':            'songs'
    'songs/:title':     'song'
    'shows?year=:year': 'showsByYear'
    'shows/:date':      'showByDate'

  showCache: {}

  index: ->
    indexData = new Streamphish.Models.IndexData
    view      = new Streamphish.Views.SiteIndex( model: indexData )

    @swap view, indexData

  songs: ->
    songs = new Streamphish.Collections.Songs
    view  = new Streamphish.Views.Songs( collection: songs )

    @swap view, songs

  song: (title) ->
    song = new Streamphish.Models.Song( id: title )
    view = new Streamphish.Views.Song( model: song )

    @swap view, song

  showsByYear: (year) ->
    shows = new Streamphish.Collections.Shows( [], year: year )
    view  = new Streamphish.Views.ShowsByYear( collection: shows )

    @swap view, shows

  showByDate: (date) ->
    show = Streamphish.ShowCache.get( date, {autoFetch: false} )
    view = new Streamphish.Views.Show( model: show )

    @swap view, show

  _swapCallback: (view) ->
    @currentView.remove() if @currentView

    @currentView = view
    @currentView.render()

    $('#player')
      .before( @currentView.$el )
      .trigger('rendered')
    $('#dim').remove()

  swap: (view, fetchable) ->
    $player = $('#player')
    $player.before('<div id="dim"></div>') if @currentView

    if !fetchable.fetched
      fetchable.fetch
        success: (model, resp, opts) =>
          @_swapCallback view
    else
      @_swapCallback view
