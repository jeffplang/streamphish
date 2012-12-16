class Streamphish.Models.Track extends Backbone.Model
  initialize: ->
    super
    @sound = soundManager.createSound
      id: @cid
      url: @get('file_url')
      autoPlay: false
      onfinish: App.player.playNext



class Streamphish.Collections.Tracks extends Backbone.Collection
  model: Streamphish.Models.Track

  # setPlaying: (track) ->
  #   currPlaying = _.find @models, (model) ->
  #     !!model.get('playing')

  #   if currPlaying
  #     currPlaying.set('playing', false) 

  #   track.set 'playing', true