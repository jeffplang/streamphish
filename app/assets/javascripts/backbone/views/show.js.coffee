class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs li': 'songClick'

  initialize: (opts) ->
    super opts
    if opts.autoloadTrack
      trackPos = @_parsePosition(opts.trackPosition)
      @model.once 'change:tracks', (model) ->
        App.player.load model.get('tracks').where(slug: opts.autoloadTrack)[0], trackPos, opts.autoPlay

    App.player.on 'change:currentTrack', @updateUrl, @

  songClick: (e) ->
    e.preventDefault() # For clicks on <a>s within the <li>
    songCid = $(e.target).closest('li').data 'cid'
    song    = @model.get('tracks').get(songCid)

    @updateUrl(song) # For when you come back to a show view and click the currently playing song
    App.player.play song

  updateUrl: (obj) ->
    if (obj instanceof Streamphish.Models.Player)
      track = obj.get('currentTrack')
    else
      track = obj
    url = "/shows/#{@model.get('show_date')}/#{track.get('slug')}"
    # We want to prevent the URL from being changed if we're calling this method
    # from the playing of an auto-loaded track
    if "/#{Backbone.history.fragment}" == url
      track.unset 'initialPosition'
      return 
    App.router.navigate url, replace: true

  _parsePosition: (posStr) ->
    # Valid position strings:
    #   1m
    #   1m30s
    #   1m30000ms
    #   90s
    #   90000ms
    return 0 if !posStr? || posStr == ''
    pieces = posStr.match /((\d+)m(?!s))?((\d+)(s|ms))?/
    pos    = 0
    if pieces[5] # seconds or milliseconds piece
      if pieces[5] == 's'
        pos += parseInt(pieces[4], 10) * 1000
      else if pieces[5] == 'ms'
        pos += parseInt(pieces[4], 10)
    if pieces[2]
      pos += parseInt(pieces[2], 10) * 60000

    pos


  remove: ->
    App.player.off 'change:currentTrack', null, @
    super

  render: ->
    super
    window.scrollTo 0, 0
