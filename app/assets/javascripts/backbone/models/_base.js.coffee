class Streamphish.Models.Base extends Backbone.Model
  fetch: (opts) ->
    _success = opts.success
    _.extend opts, 
      success: (model, resp, opts) =>
        _success(model, resp, opts)
        @fetched = true

    if window.PTData
      @set window.PTData
      window.PTData = null
      _success @
    else
      super opts


class Streamphish.Collections.Base extends Backbone.Collection
  fetch: (opts) ->
    _success = opts.success
    _.extend opts, 
      success: (model, resp, opts) =>
        _success(model, resp, opts)
        @fetched = true

    if window.PTData
      @set window.PTData
      window.PTData = null
      _success @
    else
      super opts

