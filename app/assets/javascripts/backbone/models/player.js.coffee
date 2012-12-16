class Streamphish.Models.Player extends Backbone.Model
  initialize: ->
    super
    @set 'currentTrack', null
    @on 'change:currentTrack', (model, track) ->
      @stop()
      track.sound.play()

  play: (track) ->
    @set 'playlist', track.collection if track.collection
    @set('currentTrack', track)

  stop: ->
    soundManager.stopAll();

  playPrev: ->
    currIdx = @get('playlist').indexOf @get('currentTrack')
    @set 'currentTrack', @get('playlist').at(currIdx - 1)

  playNext: ->
    currIdx = @get('playlist').indexOf @get('currentTrack')
    @set 'currentTrack', @get('playlist').at(currIdx + 1)