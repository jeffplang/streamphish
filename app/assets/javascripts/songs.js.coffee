//= require soundmanager2
//= require util

class Song
  constructor: (@$song) ->
    @$duration = @$song.find 'time.totalTime'
    @$currentTime = @$song.find 'time.currentTime'
    @songUri = @$song.data 'song-uri'
    @scrubber = new Scrubber(this)
    @$markers = @$song.find '.marker'
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
        that.updateUIPosition(this.position)

    @$song.data 'song', this

  togglePause: ->
    @sound.togglePause()

  play: ->
    @$song.addClass 'playing'
    @sound.play()

  stop: ->
    @$song.removeClass 'playing'
    @sound.stop()

  updateUIPosition: (pos) ->
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
    @$timeline = @$song.find('.scrubber')
    @$handle = @$timeline.find('.handle')

  moveToPercent: (percent) ->
    unless @$handle.hasClass('grabbed')
      @$handle.css('left', Math.round(Scrubber.distance * percent))



class ScrubberManager
  constructor: ->
    $('.songs').on 'mousedown', '.scrubber .handle', @_mouseDownHandler

    # if a mouseup event is done on the handle, a click event bubbles
    # to the song <li>...this prevents it
    $('.songs').on 'click', '.scrubber .handle', -> false

  _mouseDownHandler: (e) =>
    e.originalEvent.preventDefault() # prevents I-bar/text selection cursor from appearing
    @$currHandle = $(e.currentTarget)
    @$currScrubber = @$currHandle.closest('.scrubber')
    @currSong = @$currScrubber.closest('li').data('song')
    @handleOffset = @$currHandle.width() / 2

    @$currHandle.addClass('grabbed')
    @._toggleHandleHandlers()

  _mouseMoveHandler: (e) =>
    newPos = SP.Util.clamp e.pageX - @$currScrubber.offset().left - @handleOffset,
                           0, 
                           Scrubber.distance

    @$currHandle.css 'left', newPos

  _mouseUpHandler: (e) =>
    # TODO: update Song position on mouseup, maybe also currentTime as scrubber handle
    #       is dragged.
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
  SP.SongM = new SongManager
  SP.ScrbM = new ScrubberManager

