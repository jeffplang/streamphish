class SP.Views.Map extends SP.Views.ApplicationView
  el: '#map'
  template: SP.Templates.map

  events: 'click polygon': 'scrubToRegion'

  initialize: (@data) ->
    super

  adjustHeight: ->
    viewportHeight = Math.max document.documentElement.clientHeight, window.innerHeight or 0
    playerHeight = App.player_view.$el.height()

    mapImageHeight = @$el.find('img:first').height()
    @$el.find('svg:first').attr 'height', mapImageHeight
    # @$el.css 'height', h - playerHeight - 20

  close: ->
    $('body').removeClass 'noScroll'
    @$el.hide()

  scrubToRegion: (e) ->
    time = $(e.currentTarget).data('time')
    App.player.get('currentTrack').sound.setPosition(time)

  render: ->
    @$el.html @template(@data)
    $('body').addClass 'noScroll'    
    @$el.toggle()
    @adjustHeight()
