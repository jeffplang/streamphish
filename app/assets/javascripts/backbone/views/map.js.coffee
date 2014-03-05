class SP.Views.Map extends SP.Views.ApplicationView
  el: '#map'
  template: SP.Templates.map

  initialize: (@data) ->
    super

  adjustHeight: ->
    h = Math.max document.documentElement.clientHeight, window.innerHeight or 0
    playerHeight = App.player_view.$el.height()

    @$el.css 'height', h - playerHeight - 20

  close: ->
    $('body').removeClass 'noScroll'
    @$el.hide()

  render: ->
    # @adjustHeight()
    @$el.html @template(@data)
    $('body').addClass 'noScroll'    
    @$el.toggle()
