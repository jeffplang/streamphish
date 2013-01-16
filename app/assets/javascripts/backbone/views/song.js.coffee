class Streamphish.Views.Song extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.song

  events:
    'click ul.songs a': 'bypassLink' # weird hack to prevent song from playing on song title clicks
    'click ul.songs li': 'trackClick'

  trackClick: (e) ->
    $li      = $(e.currentTarget)
    trackIdx = $li.data 'track-idx'
    trackId  = $li.data 'track-id'
    Streamphish.ShowCache.get @model.get('tracks')[trackIdx].show.show_date,
      fetchCallback: (show) ->
        App.player.play show.get('tracks').get(trackId)
