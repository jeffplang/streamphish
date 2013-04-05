class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs li': 'songClick'

  initialize: (opts) ->
    super opts
    if opts.autoplayTrack
      trackPos = @_parsePosition(opts.trackPosition)
      @model.once 'change:tracks', (model) ->
        App.player.play model.get('tracks').where(slug: opts.autoplayTrack)[0], trackPos

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
    return if track.get('initialPosition') && track.get('initialPosition') != 0
    App.router.navigate "/shows/#{@model.get('show_date')}/#{track.get('slug')}", replace: true

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
    console.log pieces
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
    this.el.scrollTop = 0;