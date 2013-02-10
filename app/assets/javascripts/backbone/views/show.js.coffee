class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs li': 'songClick'

  initialize: (opts) ->
    super opts
    if opts.autoplayTrack
      @model.once 'change:tracks', (model) ->
        App.player.play model.get('tracks').where(slug: opts.autoplayTrack)[0]

    App.player.on 'change:currentTrack', @updateUrl, @

  songClick: (e) ->
    e.preventDefault() # For clicks on <a>s within the <li>
    songCid = $(e.currentTarget).data 'cid'
    song    = @model.get('tracks').get(songCid)

    App.player.play song

  updateUrl: ->
    App.router.navigate "/shows/#{@model.get('show_date')}/#{App.player.get('currentTrack').get('slug')}", replace: true

  remove: ->
    App.player.off 'change:currentTrack', null, @
    super

  render: ->
    super
    this.el.scrollTop = 0;