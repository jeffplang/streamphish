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
    mapImageWidth = @$el.find('img:first').width()
    @$el.find('svg:first')
      .attr('height', mapImageHeight)
      .attr('width', mapImageWidth)
    @$el.find('.wrapper').css 'width', mapImageWidth

  close: ->
    $('body').removeClass 'noScroll'
    @$el.hide()

  scrubToRegion: (e) ->
    time = $(e.currentTarget).data('time')
    App.player.get('currentTrack').goToPosition(time)

  render: ->
    @$el.html @template(@data)
    $('body').addClass 'noScroll'    
    @$el.toggle()
    @adjustHeight()
