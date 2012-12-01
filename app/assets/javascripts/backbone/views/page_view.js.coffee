class Streamphish.Views.PageView extends Backbone.View
  initialize: (options) ->
  events:
    "click a": "remoteLoad"

  remoteLoad: (e) ->
    e.preventDefault();
    console.log this