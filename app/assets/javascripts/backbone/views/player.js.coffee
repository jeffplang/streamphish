//= require 'soundmanager2-nodebug'

class Streamphish.Views.Player extends Streamphish.Views.ApplicationView
  el:        '#player'
  template:  Streamphish.Templates.player

  scrubbing: false

  events:
    'click .btn.prev':  'playPrev'
    'click .btn.next':  'playNext'
    'click .btn.playpause': 'togglePause'
    'mousedown .scrubber .handle': 'grabScrubberHandle'
    'touchdown .scrubber .handle': 'grabScrubberHandle'

  initialize: (opts) ->
    soundManager.setup
      url: '/assets/'
      useHTML5Audio: true
      preferFlash: false
      debugMode: false

    @model.on 'change:currentTrack', @trackChange, @

  playPrev: ->
    @model.playPrev()

  playNext: ->
    @model.playNext()

  togglePause: (e) ->
    $btn = $(e.currentTarget)

    @model.togglePause()
    $btn.toggleClass('play').toggleClass('pause')

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

    @$el.find('.handle').css('left', cssPos) unless @scrubbing

  grabScrubberHandle: (e) ->
    e.originalEvent.preventDefault()
    @scrubbing = true
    @$el.find('.handle').addClass 'grabbed'
    @._toggleHandleHandlers()

  _toggleHandleHandlers: ->
    $doc = $(document)

    if @scrubbing
      $scrubber        = @$el.find('.scrubber')
      $handle          = $scrubber.find('.handle')
      scrubOffset      = $scrubber.offset().left + ($handle.width() / 4)
      maxScrubDistance = $scrubber.width() - 8
      scrubPosition    = 0

      $('body').addClass 'noTextSelect'
      $doc.on 'mouseup touchend', =>
        @model.goToPercentage (scrubPosition / maxScrubDistance)
        $handle.removeClass 'grabbed'
        @scrubbing = false;
        @._toggleHandleHandlers()

      $doc.on 'mousemove touchmove', (e) ->
        scrubPosition = Streamphish.Helpers.clamp (e.clientX - scrubOffset), 0, maxScrubDistance
        $handle.css 'left', scrubPosition
    else
      $doc.off 'mouseup mousemove touchend touchmove'
      $('body').removeClass 'noTextSelect'
      

  render: ->
    $(document.body).removeClass 'hidePlayer'
    super
