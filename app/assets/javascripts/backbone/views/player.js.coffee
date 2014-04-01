class SP.Views.Player extends SP.Views.ApplicationView
  el:        '#player'
  template:  SP.Templates.player

  scrubbing: false

  events:
    'click .btn.prev':  'playPrev'
    'click .btn.next':  'playNext'
    'click .btn.playpause': 'togglePause'
    'click a.map': 'toggleMap'
    'mousedown .scrubber': 'grabScrubberHandle'
    'mousedown .scrubber .handle': 'grabScrubberHandle'
    'touchdown .scrubber .handle': 'grabScrubberHandle'

  initialize: (opts) ->
    soundManager.setup
      url: '/assets/'
      useHTML5Audio: true
      preferFlash: false
      flashVersion: 9
      debugMode: false

    @model.on 'change:currentTrack', @trackChange, @

    $(document).on 'keypress', (e) =>
      @handleKeypress(e)

  playPrev: ->
    @model.playPrev()

  playNext: ->
    @model.playNext()

  play: ->
    @model.play()
    @setPlayBtnState 'pause'

  togglePause: ->
    $btn = @$el.find('.btn.playpause')

    @model.togglePause()
    @$el.find('.btn.playpause span')
      .toggleClass('play')
      .toggleClass('pause')

  setPlayBtnState: (state) ->
    rm_state = if state == 'play' then 'pause' else 'play'

    @$el.find('.btn.playpause span').addClass(state).removeClass(rm_state)

  closeMap: ->
    @toggleMap() if @mapView
      
  toggleMap: ->
    if @mapView
      @mapView.exit()
      @mapView = null
    else
      @mapView = new SP.Views.Map(model: @model.get('currentTrack').get('map'))

      @mapView.render()

  trackChange: (player, track) ->
    @render()
    player.stop()
    track.play()

  trackLoading: (track) ->
    cssWidth = "#{Math.round(track.sound.duration / track.get('duration') * 100)}%"
    @$el.find('.loadProgress').width cssWidth

  _updateTime: (track) ->
    @$el.find('.time .current').text Streamphish.Helpers.msToMMSS track.position() unless @scrubbing

  cssPosForPercentage: (percentage) ->
    (@$el.find('.scrubber').width() - 8) * percentage

  _updateHandlePosition: (track) ->
    unless @scrubbing
      cssPos = @cssPosForPercentage(track.position() / track.get('duration'))
      @$el.find('.handle:first').css('left', cssPos) 

  trackPlaying: (track) ->
    @_updateTime track
    @trigger 'trackPlaying'
    unless App.config.isMobile
      @_updateHandlePosition track

  getScrubVars: ->
    v = $scrubber: @$el.find('.scrubber')
    v.$handle          = v.$scrubber.find('.handle')
    v.$currentTime     = @$el.find('.time .current')
    v.scrubOffset      = v.$scrubber.offset().left + (v.$handle.width() / 4)
    v.maxScrubDistance = v.$scrubber.width() - 8
    v.scrubPosition    = 0
    v

  scrubToMousePos: (e, sv) ->
    sv.scrubPosition = SP.Helpers.clamp (e.clientX - sv.scrubOffset), 0, sv.maxScrubDistance
    msPosition       = sv.scrubPosition / sv.maxScrubDistance * @model.get('currentTrack').get('duration')
    sv.$handle.css 'left', sv.scrubPosition
    sv.$currentTime.text SP.Helpers.msToMMSS(msPosition)

    msPosition

  grabScrubberHandle: (e) ->
    e.originalEvent.preventDefault()
    @scrubbing = true
    sv         = @getScrubVars()

    @scrubToMousePos e, sv
    @._toggleHandleHandlers(sv)

  _toggleHandleHandlers: (sv) ->
    $doc = $(document)

    if @scrubbing
      $('body').addClass 'noTextSelect'
      $doc.on 'mouseup touchend', =>
        @model.goToPercentage (sv.scrubPosition / sv.maxScrubDistance)
        @scrubbing = false;
        @._toggleHandleHandlers()

      $doc.on 'mousemove touchmove', (e) =>
        msPos = @scrubToMousePos e, sv
        @trigger 'scrubbing', msPos
    else
      $doc.off 'mouseup mousemove touchend touchmove'
      $('body').removeClass 'noTextSelect'
      
  handleKeypress: (e) ->
    if e.charCode == 32
      e.preventDefault()
      @togglePause() if @model.get 'currentTrack'


  render: ->
    $(document.body).removeClass 'hidePlayer'
    super
    @_updateTime @model.get('currentTrack')
    @_updateHandlePosition @model.get('currentTrack')
