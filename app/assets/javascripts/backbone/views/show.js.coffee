class Streamphish.Views.Show extends Streamphish.Views.ApplicationView
  template: Streamphish.Templates.show
  events:
    'click ul.songs li': 'songClick'

  songClick: (e) ->
    song = $.trim($(e.currentTarget).text())
    $('#player').html song
