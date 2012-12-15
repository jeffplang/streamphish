class Streamphish.Models.Show extends Backbone.Model
  urlRoot: '/shows'

  initialize: ->
    super
    @on 'change:tracks', (model, tracks) ->
      _tracks = []

      _.each tracks, (track) ->
        _tracks.push new Streamphish.Models.Track(track)

      @set 'tracks', new Streamphish.Collections.Tracks(_tracks), silent: true

  year: =>
    @get('show_date').split('-')[0]

  toJSON: ->
    json = super
    json.year = @year()
    json

class Streamphish.Collections.Shows extends Backbone.Collection
  url: '/shows'
  model: Streamphish.Models.Show

  initialize: (models, opts) ->
    @year = opts.year if opts.year
    super models, opts

  toJSON: ->
    year: @year
    shows: super

  fetch: (opts = {}) ->
    if @year
      opts.data ?= {}
      opts.data.year = @year
    super opts