class Streamphish.FastTouchLinks
  constructor: ->
    document.addEventListener 'touchstart', @, false
    document.addEventListener 'click', @, false
    document.addEventListener 'click', @cbOnClick, true
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

    document.addEventListener 'touchend', @, false
    # Why on body?  Maybe other listeners could also attach to body
    document.body.addEventListener 'touchmove', @, false

    @startX = e.touches[0].clientX
    @startY = e.touches[0].clientY

  onTouchMove: (e) ->
    if Math.abs(e.touches[0].clientX - @startX) > 10 || Math.abs(e.touches[0].clientY - @startY) > 10
      console.log 'we resetin bro'
      @reset()

  onClick: (e) ->
    e.stopPropagation()
    @reset()

    # Actually handle click/touch here
    App.router.navigate e.target.getAttribute('href'), true
    @preventGhostClick(@startX, @startY) if e.type == 'touchend'

  reset: ->
    document.removeEventListener 'touchend', @, false
    document.body.removeEventListener 'touchmove', @, false

  preventGhostClick: (x, y) ->
    console.log 'in prevent ghost'
    @cbCoords.push x, y
    window.setTimeout @cbPop, 2500

  cbPop: ->
    @cbCoords.splice 0, 2

  cbOnClick: (e) ->
    e.stopPropagation()
    e.preventDefault()
    # for coord, i in @cbCoords when (i % 2 == 0)
    #   [x, y] = [@cbCoords[i], @cbCoords[i + 1]]
    #   if Math.abs(e.clientX - x) < 25 && Math.abs(e.clientY - y) < 25
    #     e.stopPropagation()
    #     e.preventDefault()

