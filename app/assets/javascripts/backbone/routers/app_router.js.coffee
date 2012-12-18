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
    show = new Streamphish.Models.Show( id: date )
    view = new Streamphish.Views.Show( model: show )

    @swap view, show

  swap: (view, fetchable) ->
    $player = $('#player')
    $player.before('<div id="dim"></div>') if @currentView

    fetchable.fetch
      success: (model, resp, opts) =>
        @currentView.remove() if @currentView

        @currentView = view
        @currentView.render()
        $player
          .before( @currentView.$el )
          .trigger('rendered')
        $('#dim').remove()