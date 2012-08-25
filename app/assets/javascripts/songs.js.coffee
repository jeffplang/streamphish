//= require soundmanager2
//= require util

class Song
  constructor: (@$song) ->
    @songUri = @$song.data 'song-uri'
    @$scrubber = @$song.find '.songTime'
    @$duration = @$song.find 'time.totalTime'
    @$currentTime = @$song.find 'time.currentTime'
    that = this

    @sound = soundManager.createSound
      id: @songUri
      url: @songUri
      autoPlay: false
      whileloading: -> 
        that.duration = this.duration
        that.$duration
          .text(SP.Util.msToMMSS(this.duration))
      whileplaying: ->
        that.$currentTime
          .text(SP.Util.msToMMSS(this.position))

    @$song.data('sound', this)
    this.play()

  togglePause: ->
    @sound.togglePause()

  play: ->
    @$song.addClass('playing')
    @$scrubber.css('visibility', 'visible')
    @sound.play()

  stop: ->
    @$song.removeClass('playing')
    @$scrubber.css('visibility', 'hidden')
    @sound.stop()


class SongManager
  constructor: ->
    soundManager.setup
      url: '/assets/'
      useHTML5Audio: true

    @$songList = $('.songs')
    @$songList.on 'click', 'li', this.handleSongClick

  handleSongClick: (e) =>
    $song = $(e.currentTarget)
    if $song.hasClass('playing')
      $song.data('sound').togglePause()
    else
      this.playSong($song)

  playSong: ($song) ->
    this.silence();
    sound = $song.data('sound')
    unless sound?
      sound = new Song($song)
    else
      sound.play()

  silence: ->
    $playing = @$songList.find('li.playing')
    if $playing.length
      $playing.data('sound').stop()


class ScrubberManager
  pLMax: -7
  pRMax: 248

  constructor: ->
    $('.songs').on 'mousedown', '.scrubber .handle', (e) =>
      e.originalEvent.preventDefault() # prevents I-bar/text selection cursor from appearing
      e.stopPropagation()
      e.stopImmediatePropagation()
      @$currHandle = $(e.currentTarget)
      @$currScrubber = @$currHandle.closest('.scrubber')
      @handleOffset = @$currHandle.width() / 2

      this._toggleHandleHandlers()

  _toggleHandleHandlers: ->
    $doc = $(document)

    if @$currHandle?
      $doc
        .on('mousemove', (e) =>
          newPos = SP.Util.clamp e.pageX - @$currScrubber.offset().left - @handleOffset,
                                 @pLMax, 
                                 @pRMax
          @$currHandle.css 'left', newPos)

        .on('mouseup', (e) =>
          e.stopImmediatePropagation()
          e.stopPropagation()
          @$currHandle = null
          this._toggleHandleHandlers())
    else
      $doc.off('mouseup mousemove')


$ ->
  SongM = new SongManager
  ScrbM = new ScrubberManager

