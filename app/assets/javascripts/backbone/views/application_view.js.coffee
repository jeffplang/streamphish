class Streamphish.Views.ApplicationView extends Backbone.View
  events:
    "click a": "remoteLinkLoad"

  initialize: (options) ->

  remoteLinkLoad: (e) ->
    e.preventDefault()
    href = e.currentTarget.getAttribute 'href'
    App.router.navigate href, true

  render: ->
    this.$el.html this.template(this.model.toJSON());
    this