(function() {
  var Marker, Scrubber, ScrubberManager, Song, SongManager,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Song = (function() {
    function Song($song) {
      var that,
        _this = this;
      this.$song = $song;
      this.title = this.$song.data('title');
      this.show = this.$song.data('show');
      this.$duration = this.$song.find('time.totalTime');
      this.$currentTime = this.$song.find('time.currentTime');
      this.songUri = this.$song.data('song-uri');
      this.duration = this.$song.data('duration');
      this.scrubber = new Scrubber(this);
      this.$markers = this.$song.find('.marker');
      that = this;
      this.sound = soundManager.createSound({
        id: this.songUri,
        url: this.songUri,
        autoPlay: false,
        whileloading: function() {
          var width;
          that.durationLoaded = this.duration;
          width = Math.round(this.duration / that.duration * 100) + "%";
          return that.scrubber.$loadingBar.width(width);
        },
        onload: function(success) {
          if (success) {
            return that.scrubber.$loadingBar.width("100%");
          }
        },
        whileplaying: function() {
          return that.updateUIPosition(this.position);
        },
        onfinish: function() {
          return SP.SongM.playNext();
        }
      });
      this.$song.data('song', this);
      this.$markers.each(function(idx, marker) {
        var $marker;
        $marker = $(marker);
        return $marker.data('marker', new Marker(_this, $marker.data('position')));
      });
    }

    Song.prototype.togglePause = function() {
      this.sound.togglePause();
      this.$song.toggleClass('paused');
      return SP.SongM.toggleTitleAnimation();
    };

    Song.prototype.play = function() {
      if (this.sound.paused) {
        this.togglePause();
        return;
      }
      if (this.sound.playState === 1) {
        return;
      }
      this._setPageTitle();
      this.$song.addClass('playing');
      this.sound.play();
      return SP.SongM.toggleTitleAnimation();
    };

    Song.prototype.stop = function() {
      this.$song.removeClass('playing').removeClass('paused');
      this.sound.stop();
      if (SP.SongM.isTitleAnimating()) {
        return SP.SongM.toggleTitleAnimation();
      }
    };

    Song.prototype.goToPosition = function(pos) {
      if (pos > this.durationLoaded) {
        return false;
      } else {
        this.sound.setPosition(pos);
        this.updateUIPosition(pos);
        return true;
      }
    };

    Song.prototype.isPaused = function() {
      return this.sound.paused;
    };

    Song.prototype.updateCurrentTime = function(pos) {
      return this.$currentTime.text(SP.Util.msToMMSS(pos));
    };

    Song.prototype.updateUIPosition = function(pos) {
      if (!this.scrubber.$handle.hasClass('grabbed')) {
        this.updateCurrentTime(pos);
      }
      return this.scrubber.moveToPercent(pos / this.duration);
    };

    Song.prototype._setPageTitle = function() {
      var song_sep_pos;
      song_sep_pos = document.title.indexOf(":: ");
      if (song_sep_pos === -1) {
        return document.title = this.title + " :: " + (this.show || document.title);
      } else {
        return document.title = this.title + " :: " + (this.show || document.title.slice(song_sep_pos + 3, document.title.length));
      }
    };

    return Song;

  })();

  SongManager = (function() {
    function SongManager() {
      this._handleSongClick = __bind(this._handleSongClick, this);
      soundManager.setup({
        url: '/assets/',
        useHTML5Audio: true,
        preferFlash: false,
        debugMode: false
      });
      this.$songList = $('.songs');
      this.$songList.on('click', 'li', this._handleSongClick);
      this.$songList.on('click', 'li a', function(e) {
        return e.stopPropagation();
      });
    }

    SongManager.prototype._handleSongClick = function(e) {
      var $song;
      $song = $(e.currentTarget);
      if ($song.hasClass('playing')) {
        return $song.data('song').togglePause();
      } else {
        return this.playSong($song);
      }
    };

    SongManager.prototype.playSong = function($song) {
      var song;
      this.silence();
      song = $song.data('song');
      if (song == null) {
        song = new Song($song);
      }
      return song.play();
    };

    SongManager.prototype.playNext = function() {
      var $nextSong;
      $nextSong = this.$songList.children('.playing').next('li');
      if ($nextSong.length) {
        return this.playSong($nextSong);
      } else {
        return this.silence();
      }
    };

    SongManager.prototype.silence = function() {
      var $playing;
      $playing = this.$songList.children('.playing');
      if ($playing.length) {
        return $playing.data('song').stop();
      }
    };

    SongManager.prototype.isTitleAnimating = function() {
      return this._animating != null;
    };

    SongManager.prototype.toggleTitleAnimation = function() {
      var _this = this;
      this._title || (this._title = document.title);
      this._frames || (this._frames = ['~', '~', '>']);
      if (this._animating != null) {
        clearInterval(this._titleAnimation);
        document.title = this._title;
        return this._title = this._animating = null;
      } else {
        this._titleAnimation = setInterval(function() {
          _this._frames.unshift(_this._frames.pop());
          return document.title = _this._frames.join('') + " " + _this._title;
        }, 500);
        return this._animating = true;
      }
    };

    return SongManager;

  })();

  Scrubber = (function() {
    Scrubber.distance = 251;

    function Scrubber(song) {
      this.song = song;
      this.$song = this.song.$song;
      this.$scrubber = this.$song.find('.scrubber');
      this.$loadingBar = this.$song.find('.loadingProgress');
      this.$handle = this.$scrubber.find('.handle');
      this.$scrubber.data('scrubber', this);
    }

    Scrubber.prototype.moveToPercent = function(percent) {
      if (!this.$handle.hasClass('grabbed')) {
        return this.$handle.css('left', Math.round(Scrubber.distance * percent));
      }
    };

    return Scrubber;

  })();

  ScrubberManager = (function() {
    function ScrubberManager() {
      this._mouseUpHandler = __bind(this._mouseUpHandler, this);
      this._mouseMoveHandler = __bind(this._mouseMoveHandler, this);
      this._mouseDownHandler = __bind(this._mouseDownHandler, this);
      $('.songs').on('mousedown touchstart', '.scrubber .handle', this._mouseDownHandler);
      $('.songs').on('click', '.scrubber .handle', function() {
        return false;
      });
    }

    ScrubberManager.prototype._mouseDownHandler = function(e) {
      e.originalEvent.preventDefault();
      this.scrubber = $(e.currentTarget).closest('.scrubber').data('scrubber');
      this.handleOffset = this.scrubber.$handle.width() / 2;
      this.scrubberOffset = this.scrubber.$scrubber.offset().left;
      this.scrubber.$handle.addClass('grabbed');
      return this._toggleHandleHandlers();
    };

    ScrubberManager.prototype._mouseMoveHandler = function(e) {
      var newHandlePos;
      newHandlePos = SP.Util.clamp(e.pageX - this.scrubberOffset - this.handleOffset, 0, e.data.loadingWidth);
      this.potentialSongPos = Math.round(this.scrubber.song.duration * (newHandlePos / Scrubber.distance));
      this.scrubber.song.updateCurrentTime(this.potentialSongPos);
      return this.scrubber.$handle.css('left', newHandlePos);
    };

    ScrubberManager.prototype._mouseUpHandler = function(e) {
      this.scrubber.song.goToPosition(this.potentialSongPos);
      this.scrubber.$handle.removeClass('grabbed');
      this.scrubber = null;
      return this._toggleHandleHandlers();
    };

    ScrubberManager.prototype._toggleHandleHandlers = function() {
      var $doc;
      $doc = $(document);
      if (this.scrubber != null) {
        return $doc.on('mousemove touchmove', null, {
          loadingWidth: this.scrubber.$loadingBar.width()
        }, this._mouseMoveHandler).on('mouseup touchend', this._mouseUpHandler);
      } else {
        return $doc.off('mouseup mousemove touchend touchmove');
      }
    };

    return ScrubberManager;

  })();

  Marker = (function() {
    Marker.initMarkers = function() {
      return $('.marker a').on('click', function(e) {
        var marker;
        e.stopPropagation();
        marker = $(e.currentTarget).parent().data('marker');
        marker.song.goToPosition(marker.position);
        return setTimeout(function() {
          return marker.song.play();
        }, 300);
      });
    };

    function Marker(song, position) {
      this.song = song;
      this.position = position;
    }

    return Marker;

  })();

  $(function() {
    SP.SongM = new SongManager;
    SP.ScrbM = new ScrubberManager;
    return Marker.initMarkers();
  });

}).call(this);
