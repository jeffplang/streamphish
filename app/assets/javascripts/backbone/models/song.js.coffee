class Streamphish.Models.Song extends Backbone.Model
  urlRoot: '/songs'

class Streamphish.Collections.Songs extends Backbone.Collection
  url: '/songs'
  model: Streamphish.Models.Song