class SP.Models.Map extends Backbone.Model
  initialize: (data) ->
    super
    if @has('regions')
      @set 'regions',
        new SP.Collections.MapRegion( (new SP.Models.MapRegion(region) for region in @get('regions')) )
        silent: true

