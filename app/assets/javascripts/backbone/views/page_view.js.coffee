class Streamphish.Views.PageView extends Backbone.View
  initialize: (options) ->
  events:
    "click a": "remoteLinkLoad"

  remoteLinkLoad: (e) ->
    e.preventDefault();
    href = e.currentTarget.getAttribute 'href'
    App.router.navigate href, true

  render: ->
    this.$el.html this.template(this.model.toJSON());
    this