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

    App.player_view.on 'trackPlaying', @activateCurrentRegion
    App.player_view.on 'scrubbing', @highlightRegionForPos
    App.player.on 'change:currentTrack', @resetState

  adjustHeight: ->
    viewportHeight = Math.max document.documentElement.clientHeight, window.innerHeight or 0
    playerHeight = App.player_view.$el.height()

    mapImageHeight = @$el.find('img:first').height()
    mapImageWidth = @$el.find('img:first').width()
    @$el.find('svg:first')
      .attr('height', mapImageHeight)
      .attr('width', mapImageWidth)
    @$el.find('.wrapper').css 'width', mapImageWidth

  activateCurrentRegion: =>
    return if App.player_view.scrubbing or !@trackIsPlaying()

    currRegion = @model.get('regions').regionForTime(App.player.get('currentTrack').sound.position)

    if currRegion?
      unless currRegion.get('state') == 2
        @model.get('regions').attr('_aRegion', currRegion.cid)
    else
      @model.get('regions').attr('_aRegion', null)

  highlightRegionForPos: (pos) =>
    return unless @trackIsPlaying()

    currRegion = @model.get('regions').regionForTime(pos)

    if currRegion?
      return if currRegion.get('state') == 1
      if currRegion.get('state') == 2
        @model.get('regions').attr('_hlRegion', null)
      else
        @model.get('regions').attr('_hlRegion', currRegion.cid)
    else
      @model.get('regions').attr('_hlRegion', null)

  closeHandler: ->
    App.player_view.closeMap()

  exit: ->
    $('body').removeClass 'noScroll'
    @$el.hide()

    region.exit() for cid, region of @regions

    App.player_view.off 'trackPlaying', @activateCurrentRegion
    App.player_view.off 'scrubbing', @highlightRegionForPos
    App.player.off 'change:currentTrack', @resetState
    @resetState()
    @$el.unbind()

  scrubToRegion: (e) ->
    region = @model.get('regions').get($(e.currentTarget).data('cid'))

    @model.track.goToPosition(region.get('time'))
    App.player.set('currentTrack', @model.track) unless @trackIsPlaying()

    App.player_view.play()

  hoverOnRegion: (e) ->
    return unless @trackIsPlaying()
    region = @model.get('regions').get($(e.currentTarget).data('cid'))
    percentageIn = region.get('time') / App.player.get('currentTrack').get('duration')
    cssPos = App.player_view.cssPosForPercentage(percentageIn)
    App.player_view.$el.find('.handle.ghost')
      .css('left', cssPos)
      .show()

  trackIsPlaying: =>
    App.player.get('currentTrack').get('id') == @model.track.get('id')

  hideGhostHandle: ->
    App.player_view.$el.find('.handle.ghost').hide()


  resetState: =>
    @model.get('regions').attr('_hlRegion', null)
    @model.get('regions').attr('_aRegion', null)
  
  render: ->
    super

    _.each @regions, (region) ->
      region.render()

    $('body').addClass 'noScroll'
    @activateCurrentRegion()

    @$el.toggle()
    @adjustHeight()

