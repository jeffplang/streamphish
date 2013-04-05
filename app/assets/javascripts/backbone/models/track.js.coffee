class Streamphish.Models.Track extends Backbone.Model
  initialize: ->
    super

  play: (opts) ->
    soundManager.onready =>
      if !@sound
        if !@get('initialPosition') || @get('initialPosition') >= @get('duration')
          pos = 0
        else 
          pos = @get('initialPosition')
        @sound = soundManager.createSound
          id: @cid
          url: @get('file_url')
          autoPlay: false
          position: pos
          onfinish: App.player.playNext
      @sound.play opts


class Streamphish.Collections.Tracks extends Backbone.Collection
  model: Streamphish.Models.Track

  # setPlaying: (track) ->
  #   currPlaying = _.find @models, (model) ->
  #     !!model.get('playing')

  #   if currPlaying
  #     currPlaying.set('playing', false) 

  #   track.set 'playing', true