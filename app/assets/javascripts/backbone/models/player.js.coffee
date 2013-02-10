class Streamphish.Models.Player extends Backbone.Model
  # Private currently playing variable to terminate loading of current
  # track on track change
  _cSound:   null

  initialize: ->
    super
    @set 'currentTrack', null

    @on 'change:currentTrack', @stopLoadingCurrent
    @on 'change:currentTrack', @_pushTrackListenAnalytic

  play: (track) ->
    return if !track
    @set 'playlist', track.collection if track.collection
    @set 'currentTrack', track

  stop: ->
    soundManager.stopAll();

  playPrev: ->
    currIdx = @get('playlist').indexOf @get('currentTrack')
    return if currIdx == 0
    @set 'currentTrack', @get('playlist').at(currIdx - 1)

  playNext: =>
    currIdx = @get('playlist').indexOf @get('currentTrack')
    return if currIdx == @get('playlist').length - 1
    @set 'currentTrack', @get('playlist').at(currIdx + 1)

  togglePause: ->
    @get('currentTrack').sound.togglePause()

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
