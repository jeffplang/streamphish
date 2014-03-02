class Streamphish.Models.Song extends Streamphish.Models.Base
  urlRoot: '/api/v1/songs'

  # initialize: ->
  #   @on 'change:tracks', (model, tracks) ->
  #     @set 'tracks', 
  #       new Streamphish.Collections.Tracks(
  #         (new Streamphish.Models.Track(track) for track in tracks)), 
  #       silent: true

class Streamphish.Collections.Songs extends Streamphish.Collections.Base
  url: '/api/v1/songs'
  model: Streamphish.Models.Song
