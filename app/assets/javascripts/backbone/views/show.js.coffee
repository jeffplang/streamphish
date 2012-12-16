class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs > li': 'songClick'

  songClick: (e) ->
    songCid = $(e.currentTarget).data 'cid'
    song    = @model.get('tracks').get(songCid)

    App.player.play song
