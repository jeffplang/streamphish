class Streamphish.Views.Song extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.song

  events:
    'click ul.songs a': 'bypassLink' # weird hack to prevent song from playing on song title clicks
    'click ul.songs li': 'songClick'

  songClick: (e) ->
    songCid = $(e.currentTarget).data 'cid'
    console.log @model.get('tracks')
    # song    = @model.get('tracks').get(songCid)

    # App.player.play song
