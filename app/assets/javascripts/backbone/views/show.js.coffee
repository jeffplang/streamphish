class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show

  events:
    'click ul.songs li': 'songClick'

  initialize: (opts) ->
    super opts
    if opts.autoplayTrack
      @model.once 'change:tracks', (model) ->
        App.player.play model.get('tracks').where(slug: opts.autoplayTrack)[0], opts.trackPosition

    App.player.on 'change:currentTrack', @updateUrl, @

  songClick: (e) ->
    e.preventDefault() # For clicks on <a>s within the <li>
    songCid = $(e.target).closest('li').data 'cid'
    song    = @model.get('tracks').get(songCid)

    @updateUrl(song) # For when you come back to a show view and click the currently playing song
    App.player.play song

  updateUrl: (obj) ->
    if (obj instanceof Streamphish.Models.Player)
      track = obj.get('currentTrack')
    else
      track = obj
    return if track.get('initialPosition') && track.get('initialPosition') != 0
    App.router.navigate "/shows/#{@model.get('show_date')}/#{track.get('slug')}", replace: true

  remove: ->
    App.player.off 'change:currentTrack', null, @
    super

  render: ->
    super
    this.el.scrollTop = 0;