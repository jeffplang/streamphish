class SP.Models.Track extends Backbone.Model
  initialize: ->
    super
    if @has('map')
      @set 'map', new SP.Models.Map(@get('map'))
      @get('map').track = @

  play: (opts) ->
    soundManager.onready =>
      if !@sound
        if @get('initialPosition') && @get('initialPosition') < @get('duration')
          pos = @get('initialPosition')
        else 
          pos = 0

        @sound = soundManager.createSound
          id: @cid
          url: @get('file_url')
          autoPlay: false
          position: pos
          onfinish: App.player.playNext

      @sound.play
        whileloading: =>
          App.player_view.trackLoading @
        whileplaying: =>
          App.player_view.trackPlaying @

  togglePause: ->
    if !@sound
      @play()
    else
      @sound.togglePause()

  position: ->
    @sound?.position or @get('initialPosition') or 0

  goToPosition: (ms) ->
    @sound.pause()
    positionCallback = (eventPosition) ->
      @clearOnPosition 0, positionCallback
      @resume()

    @sound.onPosition 0, positionCallback
    @sound.setPosition ms
    

class SP.Collections.Tracks extends Backbone.Collection
  model: SP.Models.Track

  # setPlaying: (track) ->
  #   currPlaying = _.find @models, (model) ->
  #     !!model.get('playing')

  #   if currPlaying
  #     currPlaying.set('playing', false) 

  #   track.set 'playing', true
