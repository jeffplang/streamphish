class Streamphish.FastTouchLinks
  constructor: (el) ->
    @main = el
    @main.addEventListener 'touchstart', @, false
    @main.addEventListener 'click', @, false
    @main.addEventListener 'click', @cbOnClick, true
    @cbCoords = []

    # document.addEventListener 'touchstart', (e) ->
    #   e.stopPropagation()
    #   console.log 'touch start'
    # , false

    # document.addEventListener 'touchend', (e) -> 
    #   # e.preventDefault()
    #   # App.router.navigate e.target.getAttribute('href'), true
    #   console.log e
    # , false

  handleEvent: (e) ->
    switch e.type
      when 'touchstart' then @onTouchStart(e)
      when 'touchmove' then @onTouchMove(e)
      when 'touchend' then @onClick(e)
      when 'click' then @onClick(e)

  onTouchStart: (e) ->
    e.stopPropagation()

    @main.addEventListener 'touchend', @, false
    document.body.addEventListener 'touchmove', @, false

    @startX = e.touches[0].clientX
    @startY = e.touches[0].clientY

  onTouchMove: (e) ->
    if Math.abs(e.touches[0].clientX - @startX) > 10 || Math.abs(e.touches[0].clientY - @startY) > 10
      @reset()

  onClick: (e) ->
    e.stopPropagation()
    e.preventDefault() if e.type == 'click' # for desktop browsers, otherwise click event still goes through and does full page refresh
    @reset()

    # Actually handle click/touch here
    # This malarky is to get the actual <a> the user touched...sometimes e.target will be a <span> or <strong> otherwise
    a = @getANode(e.target)
    if a
      switch a.getAttribute('data-control')
        when 'prev' then App.player_view.playPrev()
        when 'togglePause' then App.player_view.togglePause()
        when 'next' then App.player_view.playNext()
        else
          App.router.navigate a.getAttribute('href'), true

      @preventGhostClick(@startX, @startY) if e.type == 'touchend'

  reset: ->
    @main.removeEventListener 'touchend', @, false
    document.body.removeEventListener 'touchmove', @, false

  preventGhostClick: (x, y) ->
    @cbCoords.push x, y
    window.setTimeout (=> @cbPop), 2500

  cbPop: =>
    @cbCoords.splice 0, 2

  cbOnClick: (e) =>
    for coord, i in @cbCoords when (i % 2 == 0)
      [x, y] = [@cbCoords[i], @cbCoords[i + 1]]
      if Math.abs(e.clientX - x) < 25 && Math.abs(e.clientY - y) < 25
        e.stopPropagation()
        e.preventDefault()

  getANode: (node) ->
    if node == null or node.tagName == 'A'
      return node
    else
      return @getANode(node.parentNode)
