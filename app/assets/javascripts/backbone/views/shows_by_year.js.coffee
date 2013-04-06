class Streamphish.Views.ShowsByYear extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.shows_by_year

  events: 'click header h1 a': 'toggleYearSelect'

  toggleYearSelect: (e) ->
    e.preventDefault() if e
    @yearSelect ||= document.getElementById('yearSelect')
    if @yearSelect.style.display == 'block'
      @yearSelect.style.display = 'none'
    else
      @yearSelect.style.display = 'block'

  remove: ->
    @yearSelect?.style?.display = 'none'