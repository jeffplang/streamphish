//= 'require soundmanager2-nodebug'

function msToMMSS(ms) {
  var minutes = Math.floor(ms / (1000 * 60))
    , remainingMs = ms - (minutes * 1000 * 60)
    , seconds = Math.round(remainingMs / 1000);

  return minutes + ":" + (seconds >= 10 ? "" : "0") + seconds;
}

function resetPlayingSong() {
  var $li = $('.songs li.playing')
    , $song = $li.children('a');

  if(!$li.length) return;

  $song.data('sound').stop()
  $li
    .removeClass('playing')
    .find('time.totalTime, time.currentTime')
      .css('visibility', 'hidden');
}

$(function() {
  soundManager.setup({
    url: '/assets/',
    useHTML5Audio: true
  });

  $('.songs a').on('click', function(e) {
    var $song = $(e.currentTarget)
      , $li = $song.parent()
      , songUri = $song.data('song-uri')
      , sound = $song.data('sound');

    if(!sound) {
      sound = soundManager.createSound({
        id: songUri,
        url: songUri,
        autoPlay: false,
        whileloading: function() { 
          console.log(msToMMSS(this.duration));
          $song.find('time.totalTime')
            .css('visibility', 'visible')
            .html(msToMMSS(this.duration)); 
        },
        whileplaying: function() {
          $song.find('time.currentTime')
            .css('visibility', 'visible')
            .html(msToMMSS(this.position));
        }
      });

      $song.data('sound', sound);
    }

    if(sound.playState === 0) {
      resetPlayingSong();
      $li.addClass('playing');
      sound.play();
    }
    else {
      sound.togglePause();
    }
  });

});