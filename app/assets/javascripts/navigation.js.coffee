//= require 'zepto'

class SPNav
  constructor: ->
    @_popped = true #('state' in window.history and window.history.state isnt null)
    @_initialURL = location.href

    document.addEventListener 'click', @_globalClickHandler
    window.addEventListener 'popstate', @_historyPopState

  _globalClickHandler: (e) =>
    linkEl = @_findParentWithNodeName e.target, 'A'

    if linkEl
      e.preventDefault()
      @_handleNavLink linkEl
    else if (linkEl = @_findParentWithNodeName e.target, 'LI') and linkEl.hasAttribute('data-title')
      @_handleSongLink linkEl

  _handleNavLink: (linkEl) =>
    href = linkEl.getAttribute 'href'
    Zepto.get linkEl.href, (resp) =>
      history.pushState href, null, href
      document.getElementById('main').innerHTML = resp
      Zepto(document).trigger(Zepto.Event("SP:FrontPageLoaded")) if href is '/'

  _handleSongLink: (linkEl) =>
    player = document.getElementById 'player'
    player.innerText = linkEl.getAttribute 'data-title'

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

  _findParentWithNodeName: (target, nodeName) ->
    if target is null or target.nodeName is nodeName
      return target
    else
      return @_findParentWithNodeName(target.parentElement, nodeName)


SP.Nav = new SPNav