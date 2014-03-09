class SP.Views.Map extends SP.Views.ApplicationView
  el: '#map'
  template: SP.Templates.map

  events: 'click polygon': 'scrubToRegion'

  initialize: (@data) ->
    super
    @regionTimes = _.map @data.regions, (region) ->
      region.time

    App.player_view.on 'trackPlaying', @highlightCurrentRegion

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
    pos = App.player.get('currentTrack').sound.position
    regionTime = @_regionTimeForPos pos
    if regionTime?
      @highlightRegionForTime regionTime
    else
      @_unhighlightRegions()

  close: ->
    $('body').removeClass 'noScroll'
    App.player_view.off 'trackPlaying', @highlightCurrentRegion
    @$el.hide()

  scrubToRegion: (e) ->
    time = $(e.currentTarget).data('time')
    @highlightRegionForTime time
    App.player.get('currentTrack').goToPosition(time)

  render: ->
    @$el.html @template(@data)
    $('body').addClass 'noScroll'    
    @$el.toggle()
    @adjustHeight()

  highlightRegionForTime: (time) ->
    $el = @_$elForTime(time)
    return if $el.attr('class') == 'highlight'
    @_unhighlightRegions()
    @_$elForTime(time).attr 'class', 'highlight'

  _regionTimeForPos: (pos) ->
    currRegionTime = null
    for regionTime in @regionTimes
      if pos >= regionTime
        currRegionTime = regionTime
      else if pos < regionTime
        break

    currRegionTime

  _unhighlightRegions: ->
    @$el.find('polygon.highlight').attr 'class', null

  _$elForTime: (time) ->
    @$el.find "polygon[data-time=#{time}]"
