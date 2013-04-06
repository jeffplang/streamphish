class Streamphish.Models.Track extends Backbone.Model
  initialize: ->
    super

  play: (opts) ->
    soundManager.onready =>
      if !@sound
        if !soundManager.html5.usingFlash && @get('initialPosition') && @get('initialPosition') < @get('duration')
          pos = @get('initialPosition')
        else 
          pos = 0

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