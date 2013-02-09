class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs a': (e) -> e.preventDefault()
    'click ul.songs li': 'songClick'

  initialize: (opts) ->
    super opts
    if opts.autoplayTrack
      @model.once 'change:tracks', (model) ->
        App.player.play model.get('tracks').where(slug: opts.autoplayTrack)[0]

  songClick: (e) ->
    e.stopPropagation() # Needed to keep link clicks from bubbling up, even though preventDefault was called.  weird.
    songCid = $(e.currentTarget).data 'cid'
    song    = @model.get('tracks').get(songCid)

    App.player.play song

  render: ->
    super
    this.el.scrollTop = 0;