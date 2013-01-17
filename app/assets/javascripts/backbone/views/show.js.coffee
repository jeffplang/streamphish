class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs a': 'bypassLink' # weird hack to prevent song from playing on song title clicks
    'click ul.songs li .btn.play': 'songClick'

  songClick: (e) ->
    $li     = $(e.currentTarget).parent()
    songCid = $li.data 'cid'
    song    = @model.get('tracks').get(songCid)

    @$el.find('.playing').removeClass 'playing'
    $li.addClass 'playing'

    App.player.play song

  render: ->
    super
    this.el.scrollTop = 0;