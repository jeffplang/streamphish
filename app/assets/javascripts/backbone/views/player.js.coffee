//= require 'soundmanager2-nodebug'

class Streamphish.Views.Player extends Streamphish.Views.ApplicationView
  el:        '#player'
  template:  Streamphish.Templates.player

  scrubbing: false

  events:
    'click .btn.prev':  'playPrev'
    'click .btn.next':  'playNext'
    'click .btn.playpause': 'togglePause'
    'mousedown .scrubber': 'grabScrubberHandle'
    'mousedown .scrubber .handle': 'grabScrubberHandle'
    'touchdown .scrubber .handle': 'grabScrubberHandle'

  initialize: (opts) ->
    soundManager.setup
      url: '/assets/'
      useHTML5Audio: true
      preferFlash: false
      debugMode: false

    @model.on 'change:currentTrack', @trackChange, @

    $(document).on 'keypress', (e) =>
      @handleKeypress(e)

  playPrev: ->
    @model.playPrev()

  playNext: ->
    @model.playNext()

  togglePause: ->
    # $btn = $(e.currentTarget)
    $btn = @$el.find('.btn.playpause')

    @model.togglePause()
    $btn.toggleClass('play').toggleClass('pause')

  updateHandlePosition: (cssPos) ->
    @$el.find('.handle').css('left', cssPos) unless @scrubbing

  trackChange: (player, track) ->
    @render()
    player.stop()
    track.sound.play
      whileloading: =>
        @trackLoading track
      whileplaying: =>
        @trackPlaying track

  trackLoading: (track) ->
    cssWidth = "#{Math.round(track.sound.duration / track.get('duration') * 100)}%"
    @$el.find('.loadProgress').width cssWidth

  trackPlaying: (track) ->
    maxScrubDistance = @$el.find('.scrubber').width() - 8
    cssPos = (track.sound.position / track.get('duration')) * maxScrubDistance
    @$el.find('.time .current').text Streamphish.Helpers.msToMMSS track.sound.position unless @scrubbing
    @updateHandlePosition cssPos

  getScrubVars: ->
    v = $scrubber: @$el.find('.scrubber')
    v.$handle          = v.$scrubber.find('.handle')
    v.$currentTime     = @$el.find('.time .current')
    v.scrubOffset      = v.$scrubber.offset().left + (v.$handle.width() / 4)
    v.maxScrubDistance = v.$scrubber.width() - 8
    v.scrubPosition    = 0
    v

  scrubToMousePos: (e, sv) ->
    sv.scrubPosition = Streamphish.Helpers.clamp (e.clientX - sv.scrubOffset), 0, sv.maxScrubDistance
    msPosition       = sv.scrubPosition / sv.maxScrubDistance * @model.get('currentTrack').get('duration')
    sv.$handle.css 'left', sv.scrubPosition
    sv.$currentTime.text Streamphish.Helpers.msToMMSS(msPosition)

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
        @scrubToMousePos e, sv
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
