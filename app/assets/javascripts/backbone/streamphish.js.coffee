#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.SP =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  Templates: {}
  Helpers:
    dateString: (date, fmt) ->
      # Assumes date comes in the form '1993-4-16'
      # Assumes fmt contains a '%m', '%d', and '%Y'
      date_s = date.split '-'
      d      = new Date(date_s[0], date_s[1] - 1, date_s[2])

      month  = "0#{d.getMonth() + 1}".slice -2
      day    = "0#{d.getDate()}".slice -2
      year   = d.getFullYear()

      fmt.replace('%m', month).replace('%d', day).replace('%Y', year)

    msToMMSS: (ms) ->
      minutes = Math.floor(ms / (1000 * 60))
      remainingMs = ms - (minutes * 1000 * 60)
      seconds = Math.floor(remainingMs / 1000)

      "#{ minutes }:#{if seconds < 10 then '0' else '' }#{ seconds }"

    clamp: (val, min, max) ->
      Math.max(min, Math.min(max, val))

    linkTo: (text, url) ->
      if Backbone.history._wantsPushState
        "<a href='/#{url}'>#{text}</a>"
      else
        "<a href='##{url}'>#{text}</a>"

    playerLinkToShow: (show) ->
      this.linkTo "#{this.dateString(show.get('show_date'), '%m-%d-%Y')}&nbsp;<small>#{show.get('location')}</small>", show.show_url()

    cssComplementaryColors: ->
      bgColor = '#' + Math.floor(Math.random() * 16777215).toString(16)
      fgColor = SP.Helpers.lighten(bgColor, 0.9)

      return "color: #{fgColor}; background: #{bgColor};"

    _rgbify: (colr) ->
      colr = colr.replace /#/, ''
      if colr.length is 3
        [
          parseInt(colr.slice(0,1) + colr.slice(0, 1), 16)
          parseInt(colr.slice(1,2) + colr.slice(1, 1), 16)
          parseInt(colr.slice(2,3) + colr.slice(2, 1), 16)
        ]
      else if colr.length is 6
        [
          parseInt(colr.slice(0,2), 16)
          parseInt(colr.slice(2,4), 16)
          parseInt(colr.slice(4,6), 16)
        ]
      else
        # just return black
        [0, 0, 0]

    lighten: (rgb, percent) ->
        rgb = SP.Helpers._rgbify(rgb) if typeof rgb == 'string'
     
        hsl = SP.Helpers._rgbToHsl.apply this, rgb
        lightness = hsl[2] + (hsl[2] * percent)
        lightness = Math.min 1.0, lightness
        return SP.Helpers._hexify(SP.Helpers._hslToRgb(hsl[0], hsl[1], lightness))

    # Converts an HSL color value to RGB. Conversion formula
    # adapted from http://en.wikipedia.org/wiki/HSL_color_space.
    # Assumes h, s, and l are contained in the set [0, 1] and
    # returns r, g, and b in the set [0, 255].
    #
    # @param   Number  h       The hue
    # @param   Number  s       The saturation
    # @param   Number  l       The lightness
    # @return  Array           The RGB representation
    #
    _hslToRgb: (h, s, l) ->
      if s == 0
        r = g = b = l # achromatic
      else
        hue2rgb = (p, q, t) ->
          if t < 0 then t += 1
          if t > 1 then t -= 1
          if t < 1/6 then return p + (q - p) * 6 * t
          if t < 1/2 then return q
          if t < 2/3 then return p + (q - p) * (2/3 - t) * 6
          return p
   
        q = if l < 0.5 then l * (1 + s) else l + s - l * s
        p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
   
      [r * 255, g * 255, b * 255]

    # rgb to css compatible hex color string.
    #  
    # @param   Array   rgb    An RGB color triple.
    # @return  String  rgb    The color in CSS style hex with leading "#"
    #
    _hexify: (rgb) ->
      colr = '#'
      colr += Math.floor(rgb[0]).toString(16)
      colr += Math.floor(rgb[1]).toString(16)
      colr += Math.floor(rgb[2]).toString(16)
      colr

    # Converts an RGB color value to HSL. Conversion formula
    # adapted from http://en.wikipedia.org/wiki/HSL_color_space.
    # Assumes r, g, and b are contained in the set [0, 255] and
    # returns h, s, and l in the set [0, 1].
    #
    # @param   Number  r       The red color value
    # @param   Number  g       The green color value
    # @param   Number  b       The blue color value
    # @return  Array           The HSL representation
    #
    _rgbToHsl: (r, g, b) ->
      r /= 255
      g /= 255
      b /= 255
      max = Math.max(r, g, b)
      min = Math.min(r, g, b)
      l = (max + min) / 2
   
      if max == min
        h = s = 0 # achromatic
      else
        d = max - min
        s = if l > 0.5 then d / (2 - max - min) else d / (max + min)
     
        switch max
          when r
            h = (g - b) / d + (if g < b then 6 else 0)
          when g
            h = (b - r) / d + 2
          when b
            h = (r - g) / d + 4
     
        h /= 6
     
      [h, s, l]

window.Streamphish = window.SP
