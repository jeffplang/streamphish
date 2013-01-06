//= require soundmanager2

class Streamphish.Views.Player extends Streamphish.Views.ApplicationView
  el: '#player'

  template: Streamphish.Templates.player

  events:
    'click .btn.prev':  'playPrev'
    'click .btn.next':  'playNext'
    'click .btn.playpause': 'togglePause'

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

  trackChange: (model, track) ->
    @render()
    model.stop()
    track.sound.play(
      whileloading: =>
        cssWidth = "#{Math.round(track.sound.duration / track.get('duration') * 100)}%"
        @$el.find('.loadProgress').width cssWidth
      whileplaying: =>
        cssPos = "#{track.sound.position / track.get('duration') * 100}%"
        @$el.find('.handle').css 'left', cssPos
    )

  render: ->
    $(document.body).removeClass 'hidePlayer'
    super