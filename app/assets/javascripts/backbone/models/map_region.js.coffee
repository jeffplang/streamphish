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
  clearHighlight: ->
    region = @findWhere(state: 1)
    region.set('state', 0) if region?

  setHighlight: (cid) ->
    if cid?
      region = @get(cid)
      if region.get('state') == 2
        @clearHighlight()
      else
        @clearHighlight()
        region.set('state', 1)
    else
      @clearHighlight()

  clearActive: ->
    region = @findWhere(state: 2)
    region.set('state', 0) if region?

  setActive: (cid) ->
    if cid?
      region = @get(cid)
      unless region.get('state') == 2
        @clearActive()
        region.set('state', 2)
    else
      @clearActive()

  regionForTime: (ms) ->
    _region = null

    for region in @models
      if ms >= region.get('time')
        _region = region
      else if ms < region.get('time')
        break

    _region

