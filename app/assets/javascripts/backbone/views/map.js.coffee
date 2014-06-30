class SP.Views.Map extends SP.Views.ApplicationView
  el: '#map'
  template: SP.Templates.map

  events:
    'click polygon': 'regionClick'
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

    $(document).on('keyup', @handleKeypress)

  adjustHeight: ->
    @$el.find('svg:first')
      .attr('height', @model.get('height'))
      .attr('width', @model.get('width'))
    @$el.find('.wrapper').css 'width', @model.get('width')

  regionClick: (e) ->
    region = @model.get('regions').get($(e.currentTarget).data('cid'))

    if region.has('track')
      App.player.set 'currentTrack', App.player.get('playlist').get(region.get('track'))
    else if region.has('url')
      window.open region.get('url'), '_blank'
    else
      @scrubToRegion region

  activateCurrentRegion: =>
    return if App.player_view.scrubbing or !@trackIsPlaying()

    currRegion = @model.get('regions').regionForTime(App.player.get('currentTrack').sound.position)

    if currRegion?
      return if currRegion.get('state') == 2
      @model.get('regions').setActive(currRegion.cid)
    else
      @model.get('regions').setActive(null)

  highlightRegionForPos: (pos) =>
    return unless @trackIsPlaying()

    currRegion = @model.get('regions').regionForTime(pos)

    if currRegion?
      @model.get('regions').setHighlight(currRegion.cid)
    else
      @model.get('regions').setHighlight(null)

  handleKeypress: (e) =>
    @closeHandler() if e.keyCode == 27

  closeHandler: ->
    App.player_view.closeMap()

  exit: ->
    $('body').removeClass 'noScroll'
    @$el.hide()
    @hideGhostHandle()

    region.exit() for cid, region of @regions

    App.player_view.off 'trackPlaying', @activateCurrentRegion
    App.player_view.off 'scrubbing', @highlightRegionForPos
    App.player.off 'change:currentTrack', @resetState
    $(document).off 'keyup', @handleKeypress
    @resetState()
    @$el.unbind()

  scrubToRegion: (region) ->
    @model.track.goToPosition region.get('time')
    App.player.set('currentTrack', @model.track) unless @trackIsPlaying()

    App.player_view.play()

  hoverOnRegion: (e) ->
    return unless @trackIsPlaying() 
    region = @model.get('regions').get($(e.currentTarget).data('cid'))
    return if region.has('url') or region.has('track')
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
    @model.get('regions').setHighlight(null);
    @model.get('regions').setActive(null);
  
  render: ->
    super

    _.each @regions, (region) ->
      region.render()

    $('body').addClass 'noScroll'
    @activateCurrentRegion()

    @adjustHeight()
    @$el.show()

