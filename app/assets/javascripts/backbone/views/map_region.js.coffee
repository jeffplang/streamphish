class SP.Views.MapRegion extends SP.Views.ApplicationView
  tagName: 'polygon'

  id: null
  
  initialize: (opts) ->
    super
    @map = opts.parent
    @setElement document.createElementNS('http://www.w3.org/2000/svg', 'polygon')

    @listenTo @model, 'change:state', @updateState

  _pointsStr: ->
    _.map(@model.get('points'), (coords) ->
      coords.join ','
    ).join '  '

  updateState: (model, stateIdx) =>
    @$el.attr 'class', SP.Models.MapRegion.STATES[stateIdx]

  exit: =>
    @stopListening @model

  render: =>
    @$el.attr 'points',    @_pointsStr()
    @$el.attr 'data-cid',  @model.cid

    @map.$el.find('svg').append @el
