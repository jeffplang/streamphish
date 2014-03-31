class SP.Models.MapRegion extends Backbone.Model
  pointsStr: ->
    _.map(@get('points'), (coords) ->
      coords.join ','
    ).join '  '

  toJSON: ->
    json = super
    json.pointsStr = @pointsStr()
    json


class SP.Collections.MapRegion extends Backbone.Collection
  regionForTime: (ms) ->
    _region = null

    for region in @models
      if ms >= region.get('time')
        _region = region
      else if ms < region.get('time')
        break

    _region
