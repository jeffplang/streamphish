class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs a': 'bypassLink' # weird hack to prevent song from playing on song title clicks
    'click ul.songs li': 'songClick'

  songClick: (e) ->
    songCid = $(e.currentTarget).data 'cid'
    song    = @model.get('tracks').get(songCid)

    App.player.play song

  bypassLink: (e) ->
    $(document).trigger e
    false