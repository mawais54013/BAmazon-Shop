tables = require './tables'
charts = require './charts'
colors = require './colors'

formatting = {}
module.exports = formatting
if typeof window != 'undefined'
  mode = 'browser'
else
  mode = 'console'

for style in colors.styles
    formatting[style] = colors[style]

formatting.table = tables
formatting.chart = charts
formatting.newline = formatting.n = ->
  if mode == 'console'
    return '\n'
  else if mode == 'browser'
    return '<br>'
  else
    return ''

formatting.link = formatting.href = formatting.a = (command, text) ->
  if not text and command.length == 1
    text = command[0]
  if mode == 'console'
    if command.length == 0 or command.length == 1 and command[0] == text
      return colors.underline text
    else
      return "#{text} [#{colors.underline command.join ' '}]"
  else if mode == 'browser'
    return "<a href='#!/#{command.join '/'}'>#{text}</a>"
  else
    return ''

formatting.title = formatting.h1 = (text) -> colors.yellowBG '  ' + colors.redBG colors.bold "  #{text}  " + colors.yellowBG '  '
formatting.subtitle = formatting.h2 = (text) -> colors.bold colors.cyanBG colors.yellow "  #{text}  "
formatting.subsubtitle = formatting.h3 = (text) -> colors.inverse " #{text} "
formatting.italic = formatting.i = colors.italic
formatting.bold = formatting.b = colors.bold
