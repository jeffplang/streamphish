class SP.Models.MapRegion extends Backbone.Model
  @STATES: ['default', 'highlighted', 'active']

  initialize: ->
    super
    @set 'state', 0

  pointsStr: ->
    _.map(@get('points'), (coords) ->
      coords.join ','
    ).join '  '

  toJSON: ->
    json = super
    json.pointsStr = @pointsStr()
    json


class SP.Collections.MapRegion extends Backbone.Collection
  initialize: ->
    super

    @_attributes = {}

    @on 'change:_hlRegion', @highlightChange
    @on 'change:_aRegion', @activeChange

  highlightChange: (val, oldVal) ->
    @get(oldVal)?.set 'state', 0
    @get(val)?.set 'state', 1

  activeChange: (val, oldVal) ->
    @get(oldVal)?.set 'state', 0
    @get(val)?.set 'state', 2

  attr: (prop, val) ->
    if val == undefined
      return @_attributes[prop]
    else
      oldVal = @_attributes[prop]
      return if val == oldVal
      @_attributes[prop] = val
      @trigger "change:#{prop}", val, oldVal

  regionForTime: (ms) ->
    _region = null

    for region in @models
      if ms >= region.get('time')
        _region = region
      else if ms < region.get('time')
        break

    _region

