//= require soundmanager2
//= require util

class Song
  constructor: (@$song) ->
    @$duration = @$song.find 'time.totalTime'
    @$currentTime = @$song.find 'time.currentTime'
    @songUri = @$song.data 'song-uri'
    @duration = @$song.data 'duration'
    @scrubber = new Scrubber(this)
    @$markers = @$song.find '.marker'
    that = this

    @sound = soundManager.createSound
      id: @songUri
      url: @songUri
      autoPlay: false
      whileloading: ->
        that.durationLoaded = this.duration

        width = Math.round(this.duration / that.duration * 100) + "%"
        that.scrubber.$loadingBar.width(width)
      onload: (success) ->
        that.scrubber.$loadingBar.width( "100%" ) if success
      whileplaying: ->
        that.updateUIPosition(this.position)

    @$song.data 'song', this
    @$markers.each (idx, marker) =>
      $marker = $(marker)
      $marker.data 'marker', new Marker(this, $marker.data('position'))

  togglePause: ->
    @sound.togglePause()

  play: ->
    @$song.addClass 'playing'
    @sound.play()

  stop: ->
    @$song.removeClass 'playing'
    @sound.stop()

  goToPosition: (pos) ->
    if pos > @durationLoaded
      return false
    else
      @sound.setPosition(pos)
      @updateUIPosition(pos)
      true

  updateCurrentTime: (pos) ->
    @$currentTime.text SP.Util.msToMMSS(pos)

  updateUIPosition: (pos) ->
    unless @scrubber.$handle.hasClass('grabbed')
      @updateCurrentTime pos
    @scrubber.moveToPercent pos / this.duration

class SongManager
  constructor: ->
    soundManager.setup
      url: '/assets/'
      useHTML5Audio: true
      debugMode: false

    @$songList = $('.songs')
    @$songList.on 'click', 'li', this._handleSongClick

  _handleSongClick: (e) =>
    $song = $(e.currentTarget)

    if $song.hasClass('playing')
      $song.data('song').togglePause()
    else
      this.playSong($song)

  playSong: ($song) ->
    this.silence()
    sound = $song.data('song')
    unless sound?
      sound = new Song($song)

    sound.play()

  silence: ->
    $playing = @$songList.children('.playing')
    if $playing.length
      $playing.data('song').stop()


class Scrubber
  @distance: 251

  constructor: (@song) ->
    @$song = @song.$song
    @$scrubber = @$song.find('.scrubber')
    @$loadingBar = @$song.find('.loadingProgress')
    @$handle = @$scrubber.find('.handle')

    @$scrubber.data('scrubber', this)

  moveToPercent: (percent) ->
    unless @$handle.hasClass('grabbed')
      @$handle.css('left', Math.round(Scrubber.distance * percent))

class Marker
  @initMarkers: ->
    $('.marker').on 'click', (e) ->
      e.stopPropagation()

      marker = $(e.currentTarget).data('marker')
      marker.song.goToPosition(marker.position)

  constructor: (@song, @position) ->


class ScrubberManager
  constructor: ->
    $('.songs').on 'mousedown', '.scrubber .handle', @_mouseDownHandler

    # if a mouseup event is done on the handle, a click event bubbles
    # to the song <li>...this prevents it
    $('.songs').on 'click', '.scrubber .handle', -> false

  _mouseDownHandler: (e) =>
    e.originalEvent.preventDefault() # prevents I-bar/text selection cursor from appearing

    @scrubber = $(e.currentTarget).closest('.scrubber').data('scrubber')
    @handleOffset = @scrubber.$handle.width() / 2
    @scrubberOffset = @scrubber.$scrubber.offset().left

    @scrubber.$handle.addClass 'grabbed'
    @._toggleHandleHandlers()

  _mouseMoveHandler: (e) =>
    newHandlePos = SP.Util.clamp e.pageX - @scrubberOffset - @handleOffset,
                                 0, 
                                 e.data.loadingWidth

    @potentialSongPos = Math.round( @scrubber.song.duration * (newHandlePos / Scrubber.distance) )

    @scrubber.song.updateCurrentTime @potentialSongPos
    @scrubber.$handle.css 'left', newHandlePos

  _mouseUpHandler: (e) =>
    # TODO: update Song position on mouseup, maybe also currentTime as scrubber handle
    #       is dragged.
    @scrubber.song.goToPosition @potentialSongPos
    @scrubber.$handle.removeClass('grabbed')
    @scrubber = null
    @._toggleHandleHandlers()

  _toggleHandleHandlers: ->
    $doc = $(document)

    if @scrubber?
      $doc.on('mousemove', 
              null, 
              loadingWidth: 
                @scrubber.$loadingBar.width() 
              @_mouseMoveHandler)
          .on('mouseup', @_mouseUpHandler)
    else
      $doc.off('mouseup mousemove')


$ ->
  SP.SongM = new SongManager
  SP.ScrbM = new ScrubberManager
  Marker.initMarkers()

