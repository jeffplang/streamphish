//= require soundmanager2

class Streamphish.Views.Player extends Streamphish.Views.ApplicationView
  el:        '#player'
  template:  Streamphish.Templates.player

  scrubbing: false

  events:
    'click .btn.prev':  'playPrev'
    'click .btn.next':  'playNext'
    'click .btn.playpause': 'togglePause'
    'click .scrubber': 'goToPosition'
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
    cssPos = "#{track.sound.position / track.get('duration') * 100}%"
    @$el.find('.handle').css('left', cssPos) unless @scrubbing

  goToPosition: (e) ->
    $scrubber = @$el.find('.scrubber')

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
      handleOffset     = $handle.width() / 4
      scrubberOffset   = $scrubber.offset().left
      maxScrubDistance = $scrubber.width() - 5
      scrubPosition    = 0

      $('body').addClass 'noTextSelect'
      $doc.on 'mouseup touchend', =>
        @model.goToPercentage scrubPosition / maxScrubDistance
        $handle.removeClass 'grabbed'
        @scrubbing = false;
        @._toggleHandleHandlers()

      $doc.on 'mousemove touchmove', (e) ->
        scrubPosition = Streamphish.Helpers.clamp (e.clientX - scrubberOffset - handleOffset), 0, maxScrubDistance
        $handle.css 'left', scrubPosition
    else
      $doc.off 'mouseup mousemove touchend touchmove'
      $('body').removeClass 'noTextSelect'
      

  render: ->
    $(document.body).removeClass 'hidePlayer'
    super
