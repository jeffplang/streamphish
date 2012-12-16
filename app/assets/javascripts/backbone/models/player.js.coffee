class Streamphish.Models.Player extends Backbone.Model
  initialize: ->
    super
    @set 'currentTrack', null

  play: (track) ->
    @set 'playlist', track.collection if track.collection
    @stop()
    @set 'currentTrack', track

    if !track.get('sound')
      sound = soundManager.createSound
        id: track.cid
        url: track.get('file_url')
        autoPlay: false

      track.set 'sound', sound
    track.get('sound').play()

  stop: ->
    currTrack = @get('currentTrack')
    currTrack.get('sound').stop() if currTrack and currTrack.get('sound')