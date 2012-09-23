# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  $circles  = $ 'ul.yearsCircles li'
  leftAccum = 0

  $circles
    .find('a').circlemouse
      onMouseEnter: ($el) ->
        $el.parent().addClass('hover')
      onMouseLeave: ($el) ->
        $el.parent().removeClass('hover')
    .end()
    .each (idx, el) ->
      $(el).css
        left: leftAccum
        top: Math.round(Math.sin(idx) / 2 * 30) + 10

      leftAccum = ((idx + 1) / ($circles.length + 1)) * $(window).width()
