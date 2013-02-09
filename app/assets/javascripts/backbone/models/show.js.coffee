class Streamphish.Models.Show extends Backbone.Model
  urlRoot: '/shows'

  initialize: ->
    super
    @on 'change:tracks', (model, tracks) =>
      @set 'tracks', 
           new Streamphish.Collections.Tracks( (new Streamphish.Models.Track(track) for track in tracks) )
           silent: true
      @get('tracks').show = model

  year: =>
    @get('show_date').split('-')[0]

  trackWithSlug: (slug) ->
    # Valid slugs:
    #   'wading-in-the-velvet-sea'
    #   'wading-in-the-velvet-sea--2'

    dupIdx = slug.search /--\d+$/
    if dupIdx == -1
      tIdx = 0
    else
      tIdx = parseInt(slug.substring(dupIdx + 2), 10) - 1
      slug = slug.substring(dupIdx, -1)

    @get('tracks').where(slug: slug)[tIdx]

  toJSON: ->
    json = super
    json.year = @year()
    json

  fetch: (opts) ->
    _success = opts.success
    _.extend opts, 
      success: (model, resp, opts) =>
        _success(model, resp, opts)
        @fetched = true

    super opts

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