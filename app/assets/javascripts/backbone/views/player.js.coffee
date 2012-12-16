//= require soundmanager2

class Streamphish.Views.Player extends Streamphish.Views.ApplicationView
  el: '#player'

  template: Streamphish.Templates.player

  events:
    'click .btnNav.prev':  'playPrev'
    'click .btnNav.next':  'playNext'
    'click .btnPlayPause': 'togglePause'

  initialize: (opts) ->
    soundManager.setup
      useHTML5Audio: true
      preferFlash: false
      debugMode: false

    @model.on 'change:currentTrack', @render, @

  playPrev: ->
    @model.playPrev()

  playNext: ->
    @model.playNext()

  togglePause: (e) ->
    $btn = $(e.currentTarget)

    @model.togglePause()
    if @model.isPaused()
      $btn.text 'play'
    else
      $btn.text 'pause'
