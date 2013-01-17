class Streamphish.Views.Song extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.song

  events:
    'click ul.songs a': 'bypassLink' # weird hack to prevent song from playing on song title clicks
    'click ul.songs li .btn.play': 'trackClick'

  trackClick: (e) ->
    $li      = $(e.currentTarget).parent()
    trackIdx = $li.data 'track-idx'
    trackId  = $li.data 'track-id'
    Streamphish.ShowCache.get @model.get('tracks')[trackIdx].show.show_date,
      fetchCallback: (show) =>
        @$el.find('.playing').removeClass 'playing'
        $li.addClass 'playing'

        App.player.play show.get('tracks').get(trackId)
