class Streamphish.Models.ShowCache
  shows: {}

  get: (showDate, opts={}) ->
    _.defaults opts,
      autoFetch: true

    @shows[showDate] = new Streamphish.Models.Show(id: showDate) if !@shows[showDate]

    if !@shows[showDate].fetched && opts.autoFetch
      @shows[showDate].fetch
        success: opts.fetchCallback
    else if opts.fetchCallback
      opts.fetchCallback(@shows[showDate])

    @shows[showDate]

Streamphish.ShowCache = new Streamphish.Models.ShowCache