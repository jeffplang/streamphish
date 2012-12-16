//= require soundmanager2

class Streamphish.Views.Player extends Streamphish.Views.ApplicationView
  el: '#player'
  template: Streamphish.Templates.player

  initialize: (opts) ->
    soundManager.setup
      useHTML5Audio: true
      preferFlash: false
      debugMode: false

    @model.on 'change:playlist', @render, @
    @model.on 'change:currentTrack', @render, @
