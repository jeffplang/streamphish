class Streamphish.Models.Show extends Backbone.Model
  urlRoot: '/shows'

  year: =>
    @.attributes.show_date.split('-')[0]

  toJSON: ->
    json = super
    json.year = @.year()
    json


class Streamphish.Collections.Shows extends Backbone.Collection
  url: '/shows'
  model: Streamphish.Models.Show

  initialize: (models, opts) ->
    @year = opts.year if opts.year
    super models, opts

  fetch: (opts = {}) ->
    if @year
      opts.data ?= {}
      opts.data.year = @year
    super opts

  toJSON: ->
    year: @year
    shows: super
