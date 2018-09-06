# module 'charts'

{bold, white, yellow, magenta, red, cyan, green} = require './colors'

module.exports = (opts) ->
  defaultOpts =
    _show_legend: true
    _fill: true
    _interpolate: 'cubic'
    _height: '300px'
    _style: 'dark'
  for opt of defaultOpts
    opts[opt] = opts[opt] or defaultOpts[opt]

  if typeof window != 'undefined'
    mode = 'browser'
    url = "http://charts.brace.io/bar.svg?"
    url += "#{name}=#{values.join ','}&" for name, values of opts
    return "<object data='#{url}' type='image/svg+xml'>"

  else
    mode = 'console'
    tick = '▇'
    series = {}

    # identify series
    for name, vals of opts when name[0] != '_'
      series[name] = vals

    # identify maximum label word length
    maxlabel = 0
    if '_labels' of opts
      maxlabel = label.length for label in opts._labels when label.length > maxlabel

    # a scale function for value normalization
    scale = ( ->
      absMax = opts._absolute_max or 70
      if maxlabel
        absMax -= (maxlabel + 2)
      relMax = 0
      for l, vals of series
        relMax = val for val in vals when val > relMax
      return (val) -> parseInt( (val/relMax) * absMax )
    )()

    # colors for series
    colors = [white, yellow, magenta, red, cyan, green]

    # generate chart
    output = '\n'
    serien = 0
    for name, values of series
      color = colors[serien % colors.length]
      output += bold name + ' '
      output += '\n'
      i = 0
      for val in values
        normalized = scale val # normalize
        if maxlabel
          output += opts._labels[i]
          if opts._labels[i].length
            output += ' ' for space in [opts._labels[i].length..maxlabel]
        output += color tick for n in [0..normalized]
        output += ' ' + val if opts._show_legend
        output += '\n'
        i += 1
      serien += 1
      output += '\n'
    return output
