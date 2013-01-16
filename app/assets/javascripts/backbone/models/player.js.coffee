class Streamphish.Models.Player extends Backbone.Model
  initialize: ->
    super

    @set 'currentTrack', null

  play: (track) ->
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
