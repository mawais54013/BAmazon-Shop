# module 'tables'


module.exports = (header, rows, opts={}) ->
  # header: [] or null
  # rows: [[]]

  colors = require './colors'
  formatting = require './formatting'
  String.prototype.len = ->
    @.split()[0].replace(/<([^>]*)>/g, '')
                .replace(/\[[^m]+m/g, '').length

  if header and header.length
    rows.unshift header # everything is a normal row
    header = true

  # normalize opts
  defaultOpts =
    kind: 'horizontal'
    borderColor: 'magenta'
    headerColor: 'bold'
    textColor: 'yellow'
    numberColor: 'cyan'
  styles = {}
  for opt of defaultOpts
    if opt not in opts
      opts[opt] = defaultOpts[opt]
    styles[opt] = colors[opts[opt]]
  {borderColor, headerColor, textColor, numberColor} = styles

  # get number of cols
  ncols = 0
  for row in rows
    ncols = row.length if row.length > ncols

  cols = [0..(ncols-1)]

  # keep a parallel array with the contents styled
  styledRows = []
  for row in rows
    styledRows.push ('' for col in row)

  # keep a parallel array with the contents non-stringified
  rawRows = []
  for row in rows
    rawRows.push (col for col in row)

  largest = {}
  for col in cols
    for row, i in rows
      # style content according to its type
      styledRow = styledRows[i]
      if typeof row[col] == 'number' or /\d+,\d+/.exec row[col]
        styledContent = numberColor row[col]
      else if typeof row[col] == 'string'
        styledContent = textColor row[col]
      styledRow[col] = styledContent

      # stringify everything
      row[col] = "#{row[col]}" if row[col]

    # get largest content in each column
    largest[col] = 0
    for row in rows
      largest[col] = row[col].len() if row[col] and row[col].len() > largest[col]

  # helper functions
  buildLine = (style=borderColor) ->
    line = ''
    line += borderColor '+'
    for col in cols
      line += style '-' # padding left
      for char in [0..largest[col]]
        line += style '-'
      line += borderColor '+' # padding right
    line += formatting.newline()
    return line

  buildRow = (row, styledRow, rawRow, defaultAlign='auto') ->
    line = ''
    line += borderColor '|'
    for col in cols
      line += ' ' # padding left

      # define alignment
      if defaultAlign == 'auto'
        if typeof rawRow[col] == 'number' or /\d+,\d+/.exec rawRow[col]
          align = 'right'
        else
          align = 'left'
      else
        align = defaultAlign

      spaces = largest[col]
      spaces -= row[col].len() if row.length-1 >= col
      spacesBefore = getSpacesBefore spaces, align
      spacesAfter = spaces - spacesBefore

      # spaces before the content
      while spacesBefore > 0
        line += ' '
        spacesBefore--

      # the content itself
      if typeof styledRow == 'function'
        stylize = styledRow
        styledContent = stylize row[col]
      else
        styledContent = styledRow[col]
      line += styledContent

      # spaces after the content
      while spacesAfter > 0
        line += ' '
        spacesAfter--
        
      line += borderColor ' |' # padding right
    line += formatting.newline()
    return line

  getSpacesBefore = (spacesLeft, align) ->
    if align == 'left'
      return 0
    else if align == 'right'
      return spacesLeft
    else if align == 'center'
      if spacesLeft % 2 == 0 # even
        return spacesLeft/2
      else # odd
        return (spacesLeft-1)/2

  # build the table as a string
  output = ''

  # top line
  output += buildLine()

  # header
  if header
    output += buildRow rows[0], headerColor, null, 'center'
    output += buildLine headerColor
    rows = rows.slice(1)
    styledRows = styledRows.slice(1)
    rawRows = rawRows.slice(1)

  # body
  for row, i in rows
    styledRow = styledRows[i]
    rawRow = rawRows[i]
    output += buildRow row, styledRow, rawRow

  # closing
    output += buildLine()

  return output
