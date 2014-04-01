class SP.Views.Map extends SP.Views.ApplicationView
  el: '#map'
  template: SP.Templates.map

  events:
    'click polygon': 'scrubToRegion'
    'click a.closeBtn': 'closeHandler'
    'mouseover polygon': 'hoverOnRegion'
    'mouseout polygon': 'hideGhostHandle'

  initialize: ->
    super

    @regions = {}

    for region in @model.get('regions').models
      @regions[region.cid] = new SP.Views.MapRegion(model: region, parent: @)

    App.player_view.on 'trackPlaying', @highlightCurrentRegion
    App.player_view.on 'scrubbing', @highlightRegionForPos

  adjustHeight: ->
    viewportHeight = Math.max document.documentElement.clientHeight, window.innerHeight or 0
    playerHeight = App.player_view.$el.height()

    mapImageHeight = @$el.find('img:first').height()
    mapImageWidth = @$el.find('img:first').width()
    @$el.find('svg:first')
      .attr('height', mapImageHeight)
      .attr('width', mapImageWidth)
    @$el.find('.wrapper').css 'width', mapImageWidth

  highlightCurrentRegion: =>
    return if App.player_view.scrubbing
    currRegion = @model.get('regions').regionForTime(App.player.get('currentTrack').sound.position)

    if currRegion?
      unless currRegion.get('highlighted')
        @_unhighlightRegions()
        currRegion.set 'highlighted', true
    else
      @_unhighlightRegions()

  closeHandler: ->
    App.player_view.closeMap()

  exit: ->
    $('body').removeClass 'noScroll'
    @$el.hide()

    App.player_view.off 'trackPlaying', @highlightCurrentRegion
    App.player_view.off 'scrubbing', @highlightRegionForPos
    @$el.unbind()
    @_unhighlightRegions()

  scrubToRegion: (e) ->
    region = @model.get('regions').get($(e.currentTarget).data('cid'))

    App.player.get('currentTrack').goToPosition(region.get('time'))
    App.player_view.play()

  hoverOnRegion: (e) ->
    region = @model.get('regions').get($(e.currentTarget).data('cid'))
    percentageIn = region.get('time') / App.player.get('currentTrack').get('duration')
    cssPos = App.player_view.cssPosForPercentage(percentageIn)
    App.player_view.$el.find('.handle.ghost')
      .css('left', cssPos)
      .show()

  hideGhostHandle: ->
    App.player_view.$el.find('.handle.ghost').hide()

  highlightRegionForPos: (pos) =>
    currRegion = @model.get('regions').regionForTime(pos)

    if currRegion?
      unless currRegion.get('highlighted')
        @_unhighlightRegions()
        currRegion.set('highlighted', true)
    else
      @_unhighlightRegions()


  _unhighlightRegions: ->
    for region in @model.get('regions').models
      if region.get('highlighted')
        region.set 'highlighted', false
        break

  render: ->
    super

    _.each @regions, (region) ->
      region.render()

    $('body').addClass 'noScroll'
    @highlightCurrentRegion()

    @$el.toggle()
    @adjustHeight()

