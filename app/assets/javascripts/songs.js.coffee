//= require soundmanager2

class Song
  constructor: (@$song) ->
    @songUri = @$song.data 'song-uri'
    @$wrapper = @$song.parent()
    @$duration = @$song.find 'time.totalTime'
    @$currentTime = @$song.find 'time.currentTime'
    that = this

    @sound = soundManager.createSound
      id: @songUri
      url: @songUri
      autoPlay: true
      whileloading: -> 
        that.duration = this.duration
        that.$duration
          .text(SongManager.msToMMSS(this.duration))
          .css('visibility', 'visible')
      whileplaying: ->
        that.$currentTime
          .text(SongManager.msToMMSS(this.position))
          .css('visibility', 'visible')

    @$song
      .data('sound', this)
      .parent().addClass('playing')

  togglePause: ->
    @sound.togglePause()

  play: ->
    @$wrapper.addClass('playing')
    @$duration.css('visibility', 'visible')
    @sound.play()

  stop: ->
    @$currentTime.css('visibility', 'hidden')
    @$duration.css('visibility', 'hidden')
    @$wrapper.removeClass('playing')
    @sound.stop()


class SongManager
  @msToMMSS: (ms) ->
    minutes = Math.floor(ms / (1000 * 60))
    remainingMs = ms - (minutes * 1000 * 60)
    seconds = Math.round(remainingMs / 1000)

    "#{ minutes }:#{if seconds < 10 then '0' else '' }#{ seconds }"

  constructor: ->
    soundManager.setup
      url: '/assets/'
      useHTML5Audio: true

    @$songList = $('.songs')
    @$songList.on 'click', 'li a', this.handleSongClick

  handleSongClick: (e) =>
    $song = $(e.currentTarget)
    if $song.parent().hasClass('playing')
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
    log 'SILENCING'
    $playing = @$songList.find('li.playing a')
    if $playing.length
      log $playing.data('sound')
      $playing.data('sound').stop()

SM = new SongManager
