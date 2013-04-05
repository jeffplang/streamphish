class Streamphish.Routers.AppRouter extends Backbone.Router

  routes:
    '':                     'index'
    'songs':                'songs'
    'songs/:title':         'song'
    # 'shows?:year_query':    'showsByYear'
    'shows/:date(/:track)': 'showByDate'

  showCache: {}

  initialize: ->
    super
    @bind 'all', @_trackPageView
    @_dim = document.getElementById 'dim'

  index: ->
    indexData = new Streamphish.Models.IndexData
    view      = new Streamphish.Views.SiteIndex( model: indexData )

    @_swap view, indexData

  songs: ->
    songs = new Streamphish.Collections.Songs
    view  = new Streamphish.Views.Songs( collection: songs )

    @_swap view, songs

  song: (title) ->
    song = new Streamphish.Models.Song( id: title )
    view = new Streamphish.Views.Song( model: song )

    @_swap view, song

  showsByYear: (year) ->
    shows = new Streamphish.Collections.Shows( [], year: year )
    view  = new Streamphish.Views.ShowsByYear( collection: shows )

    @_swap view, shows


  showByDate: (date, track, params) ->
    # determine if date is a year
    if date.match(/^\d{4}$|^83-87$/)
      @showsByYear(date)
    else
      show = Streamphish.ShowCache.get( date, {autoFetch: false} )
      view = new Streamphish.Views.Show( model: show, autoplayTrack: track, trackPosition: params?.t )

      @_swap view, show

  _swapCallback: (view) ->
    @currentView.remove() if @currentView

    @currentView = view
    @currentView.render()

    $('#main').html( @currentView.$el )
      # .trigger('rendered')
    @_dim.style.display = 'none'

  _swap: (view, fetchable) ->
    @_dim.style.display = 'block' if @currentView

    if !fetchable.fetched
      fetchable.fetch
        success: (model, resp, opts) =>
          @_swapCallback view
    else
      @_swapCallback view

  _trackPageView: ->
    url = Backbone.history.getFragment()
    _gaq.push ['_trackPageview', "/#{url}"]
