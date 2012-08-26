//= require soundmanager2
//= require util

class Song
  constructor: (@$song) ->
    @$duration = @$song.find 'time.totalTime'
    @$currentTime = @$song.find 'time.currentTime'
    @songUri = @$song.data 'song-uri'
    @scrubber = new Scrubber(this)
    that = this

    @sound = soundManager.createSound
      id: @songUri
      url: @songUri
      autoPlay: false
      whileloading: -> 
        that.duration = this.durationEstimate
        that.$duration
          .text SP.Util.msToMMSS(that.duration)
      onload: ->
        that.duration = this.duration
      whileplaying: ->
        that.updatePosition(this.position)

    @$song.data('sound', this)

  togglePause: ->
    @sound.togglePause()

  play: ->
    @$song.addClass 'playing'
    @sound.play()

  stop: ->
    @$song.removeClass 'playing'
    @sound.stop()

  updatePosition: (pos) ->
    @$currentTime.text SP.Util.msToMMSS(pos)
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
    log 'in handle song click'
    $song = $(e.currentTarget)
    # event for 'mouseup' on scrubber handle always fires after this, 
    # due to it being a handler on $(document)?  Hence this hack.
    if $song.find('.handle').hasClass('grabbed')
      log 'it is being grabbed'
      return

    if $song.hasClass('playing')
      $song.data('sound').togglePause()
    else
      this.playSong($song)

  playSong: ($song) ->
    this.silence()
    sound = $song.data('sound')
    unless sound?
      sound = new Song($song)

    sound.play()

  silence: ->
    $playing = @$songList.children('.playing')
    if $playing.length
      $playing.data('sound').stop()


class Scrubber
  @pLMax: -7
  @pRMax: 248

  constructor: (@song) ->
    @$song = @song.$song
    @$timeline = @$song.find('.scrubber')
    @$handle = @$timeline.find('.handle')

  moveToPercent: (percent) ->
    unless @$handle.hasClass('grabbed')
      distance = Scrubber.pRMax - Scrubber.pLMax
      newPos = Math.round(distance * percent) + Scrubber.pLMax

      @$handle.css('left', newPos)


class ScrubberManager
  constructor: ->
    $('.songs').on 'mousedown', '.scrubber .handle', @_mouseDownHandler

  _mouseDownHandler: (e) =>
    e.originalEvent.preventDefault() # prevents I-bar/text selection cursor from appearing
    @$currHandle = $(e.currentTarget)
    @$currTimeline = @$currHandle.closest('.scrubber')
    @handleOffset = @$currHandle.width() / 2

    @$currHandle.addClass('grabbed')
    @._toggleHandleHandlers()

  _mouseMoveHandler: (e) =>
    newPos = SP.Util.clamp e.pageX - @$currTimeline.offset().left - @handleOffset,
                           Scrubber.pLMax, 
                           Scrubber.pRMax
    @$currHandle.css 'left', newPos

  _mouseUpHandler: (e) =>
    log 'mouse up'
    @$currHandle.removeClass('grabbed')
    @$currHandle = null
    @._toggleHandleHandlers()

  _toggleHandleHandlers: ->
    $doc = $(document)

    if @$currHandle?
      $doc.on('mousemove', @_mouseMoveHandler)
          .on('mouseup', @_mouseUpHandler)
    else
      $doc.off('mouseup mousemove')

$ ->
  SP.ScrbM = new ScrubberManager
  SP.SongM = new SongManager

