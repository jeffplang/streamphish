class Streamphish.Models.Player extends Backbone.Model
  # Private currently playing variable to terminate loading of current
  # track on track change
  _cSound:   null

  initialize: ->
    super
    @set 'currentTrack', null

    @on 'change:currentTrack', @stopLoadingCurrent
    @on 'change:currentTrack', @_pushTrackListenAnalytic

  load: (track, pos = 0, autoStart = false) ->
    return if !track
    # On FF (and other browsers that use flash?), @play may be called before 
    # soundManager is ready, such as when a user directly visits a show page
    # with an autoPlay track (i.e. /shows/1994-06-26/wilson)
    soundManager.onready =>
      @set 'playlist', track.collection if track.collection

      # Since we don't support time linking on flash audio browsers (b/c file
      # has to load from beginning to the given time), always set initialPosition 
      # to 0
      track.set 'initialPosition', (if soundManager.html5.usingFlash then 0 else pos)

      # Mobile's can't play audio without user action, so always prevent autoStart
      # for them
      if autoStart
        @set 'currentTrack', track
      else
        @set 'currentTrack', track, silent: true
        App.player_view.render()
        document.getElementById('playBtn').children[0].className = 'play'

  play: (track, pos = 0) ->
    @load track, pos, true

  stop: ->
    soundManager.stopAll()

  playPrev: ->
    currIdx = @get('playlist').indexOf @get('currentTrack')
    return if currIdx == 0
    @set 'currentTrack', @get('playlist').at(currIdx - 1)

  playNext: =>
    currIdx = @get('playlist').indexOf @get('currentTrack')
    return if currIdx == @get('playlist').length - 1
    @set 'currentTrack', @get('playlist').at(currIdx + 1)

  togglePause: ->
    @get('currentTrack').togglePause()

  isPaused: ->
    @get('currentTrack').sound.paused

  goToPercentage: (percentage) ->
    duration = @get('currentTrack').get('duration')
    @get('currentTrack').sound.setPosition(duration * percentage)

  stopLoadingCurrent: (player, newTrack) ->
    @_cSound.unload() if @_cSound
    @_cSound = newTrack.sound

  _pushTrackListenAnalytic: (player, track) =>
    trackUrl = "/shows/#{track.collection.show.get('show_date')}/#{track.get('slug')}"
    _gaq.push ['_trackEvent', 'track', 'listen', trackUrl]
