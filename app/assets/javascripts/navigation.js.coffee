//= require 'zepto'

class SPNav
  constructor: ->
    @_popped = ('state' in window.history and window.history.state isnt null)
    @_initialURL = location.href

    document.addEventListener 'click', @_navClickHandler
    window.addEventListener 'popstate', @_historyPopState

  _navClickHandler: (e) =>
    linkEl = @_findParentLink e.target

    if linkEl
      e.preventDefault()
      href = linkEl.getAttribute 'href'
      Zepto.get linkEl.href, (resp) =>
        history.pushState href, null, href
        document.getElementById('main').innerHTML = resp
        Zepto(document).trigger(Zepto.Event("SP:FrontPageLoaded")) if href is '/'

  _historyPopState: (e) =>
    # Handle Chrome's popState firing on page load
    initialPop = !@_popped and location.href is @_initialURL
    @_popped = true
    return if initialPop

    url = e.state || "/"
    # Add date string to URL to prevent caching
    if url is '/'
      url += if /\?/.test(url) then "&" else "?"
      url += (new Date).getTime()

    Zepto.get url, (resp) =>
      document.getElementById('main').innerHTML = resp
      Zepto(document).trigger(Zepto.Event("SP:FrontPageLoaded")) if /^\/\?/.test url
        
  _handleChromeOnloadPopstate: =>
    initialPop = !@_popped and @_initialURL is location.href
    @_popped = true
    initialPop

  _findParentLink: (target) ->
    if target is null or target.nodeName is 'A'
      return target
    else
      return @_findParentLink(target.parentElement)


SP.Nav = new SPNav