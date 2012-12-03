class Streamphish.Views.SiteIndex extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.site_index

  initialize: (options) ->

  render: ->
    super

    $songsC = $ 'div.songs'
    $songs  = $songsC.children 'a'
    $years  = $ 'ul.yearsCircles li'
    $win    = $ window

    $songsC.height $win.height() - $songsC.offset().top

    $songs
      .circlemouse
        onMouseEnter: ($el) ->
          $el.addClass 'hover'
        onMouseLeave: ($el) ->
          $el.removeClass 'hover'
      .each (i, el) ->
        $el   = $(el)
        $span = $el.children 'span'
        randomSize = Streamphish.Util.clamp($span.width() + 40, 80, 146)
        maxHeight = Math.min 300, $songsC.height()

        $el.css
          width: randomSize
          height: randomSize
          top: Math.max( 0,
            Math.sin( (i / $songs.length) * Math.PI ) * maxHeight - $el.height() )
          left: (i / $songs.length) * $songsC.width() - i - 1

        if $span.height() <= 24
          $span.css 'top', $el.height()/2 - $span.height()/1.5
        else if $span.height() <= 53
          $span.css 'top', $el.height()/2 - $span.height()/2.1
        else if $span.height() <= 82
          $span.css 'top', $el.height() * 0.30
        else if $span.height() <= 111
          $span.css 'top', $el.height() * 0.30


    $years
      .find('a').circlemouse
        onMouseEnter: ($el) ->
          $el.parent().addClass 'hover'
        onMouseLeave: ($el) ->
          $el.parent().removeClass 'hover'
      .end()
      .each (i, el) ->
        $(el).css
          left: (i / $years.length) * $win.width() - i
          top: Math.round(Math.sin(i) / 2 * 30) + 10
