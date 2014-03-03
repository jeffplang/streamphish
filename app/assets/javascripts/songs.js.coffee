class Song
  constructor: (@$song) ->
    @title = @$song.data 'title'
    @show = @$song.data 'show'
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
      onfinish: ->
        SP.SongM.playNext()

    @$song.data 'song', this
    @$markers.each (idx, marker) =>
      $marker = $(marker)
      $marker.data 'marker', new Marker(this, $marker.data('position'))

  togglePause: ->
    @sound.togglePause()
    @$song.toggleClass 'paused'
    SP.SongM.toggleTitleAnimation()

  play: ->
    if @sound.paused
      @togglePause()
      return

    return if @sound.playState is 1

    @_setPageTitle()

    @$song.addClass 'playing'
    @sound.play()
    SP.SongM.toggleTitleAnimation()

  stop: ->
    @$song.removeClass('playing').removeClass('paused')
    @sound.stop()
    SP.SongM.toggleTitleAnimation() if SP.SongM.isTitleAnimating()

  goToPosition: (pos) ->
    if pos > @durationLoaded
      return false
    else
      @sound.setPosition(pos)
      @updateUIPosition(pos)
      true

  isPaused: ->
    @sound.paused

  updateCurrentTime: (pos) ->
    @$currentTime.text SP.Util.msToMMSS(pos)

  updateUIPosition: (pos) ->
    unless @scrubber.$handle.hasClass('grabbed')
      @updateCurrentTime pos
    @scrubber.moveToPercent pos / this.duration

  _setPageTitle: ->
    song_sep_pos = document.title.indexOf(":: ")
    if song_sep_pos == -1
      document.title = @title + " :: " + (@show || document.title)
    else
      document.title = @title + " :: " + (@show || document.title.slice(song_sep_pos + 3, document.title.length))



class SongManager
  constructor: ->
    soundManager.setup
      url: '/assets/'
      useHTML5Audio: true
      preferFlash: false
      debugMode: false

    @$songList = $('.songs')
    @$songList.on 'click', 'li', this._handleSongClick
    @$songList.on 'click', 'li a', (e) -> e.stopPropagation();

  _handleSongClick: (e) =>
    $song = $(e.currentTarget)

    if $song.hasClass('playing')
      $song.data('song').togglePause()
    else
      @playSong($song)

  playSong: ($song) ->
    @silence()
    song = $song.data('song')
    unless song?
      song = new Song($song)

    song.play()

  playNext: ->
    # Assumes other sounds have been stopped
    $nextSong = @$songList.children('.playing').next('li')
    if $nextSong.length
      @playSong($nextSong)
    else
      @silence()

  silence: ->
    $playing = @$songList.children('.playing')
    if $playing.length
      $playing.data('song').stop()

  isTitleAnimating: ->
    @_animating?

  toggleTitleAnimation: ->
    @_title ||= document.title
    @_frames ||= ['~', '~', '>']

    if @_animating?
      clearInterval @_titleAnimation
      document.title = @_title
      @_title = @_animating = null
    else
      @_titleAnimation = setInterval =>
        @_frames.unshift @_frames.pop()
        document.title = @_frames.join('') + " " + @_title
      , 500
      @_animating = true


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


class ScrubberManager
  constructor: ->
    $('.songs').on 'mousedown touchstart', '.scrubber .handle', @_mouseDownHandler

    # if a mouseup event is done on the handle, a click event bubbles
    # to the song <li>...this prevents it
    $('.songs').on 'click', '.scrubber .handle', -> false

  _mouseDownHandler: (e) =>
    e.originalEvent.preventDefault() # prevents I-bar/text selection cursor from appearing

    @scrubber = $(e.currentTarget).closest('.scrubber').data('scrubber')
    @handleOffset = @scrubber.$handle.width() / 2        # These values are cached to keep the 
    @scrubberOffset = @scrubber.$scrubber.offset().left  # mouseMoveHandler speedy

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
    @scrubber.song.goToPosition @potentialSongPos
    @scrubber.$handle.removeClass('grabbed')
    @scrubber = null
    @._toggleHandleHandlers()

  _toggleHandleHandlers: ->
    $doc = $(document)

    if @scrubber?
      $doc.on('mousemove touchmove', 
              null, 
              loadingWidth: 
                @scrubber.$loadingBar.width() 
              @_mouseMoveHandler)
          .on('mouseup touchend', @_mouseUpHandler)
    else
      $doc.off('mouseup mousemove touchend touchmove')


class Marker
  @initMarkers: ->
    $('.marker a').on 'click', (e) ->
      e.stopPropagation()

      marker = $(e.currentTarget).parent().data('marker')
      marker.song.goToPosition(marker.position)

      # doing a setPosition() with a togglePause() immediately after on
      # an SMSound object ignores the setPosition() call in most cases,
      # maybe some race condition in the flash player?
      setTimeout ->      
        marker.song.play()
      , 300

  constructor: (@song, @position) ->


$ ->
  SP.SongM = new SongManager
  SP.ScrbM = new ScrubberManager
  Marker.initMarkers()
