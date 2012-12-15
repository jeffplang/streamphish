class Streamphish.Views.ApplicationView extends Backbone.View
  events:
    "click a": "remoteLinkLoad"

  tagName: 'div'
  id: 'main'

  initialize: (options) ->

  remoteLinkLoad: (e) ->
    e.preventDefault()
    href = e.currentTarget.getAttribute 'href'
    App.router.navigate href, true

  render: ->
    # This hack is if this.model is a collection.  Underscore templates expect
    # data to come in an object (to be used in a with statement), or for the 
    # 'variable' option to be passed in during the compilation step.

    modelJSON = this.model.toJSON()
    if modelJSON instanceof Array
      modelJSON = {data: modelJSON} 

    this.$el.html this.template(modelJSON)
    this