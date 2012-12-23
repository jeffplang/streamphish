class Streamphish.Models.Tour extends Backbone.Model
  urlRoot: '/tours'

class Streamphish.Collections.Tours extends Backbone.Collection
  url: '/tours'
  model: Streamphish.Models.Tour