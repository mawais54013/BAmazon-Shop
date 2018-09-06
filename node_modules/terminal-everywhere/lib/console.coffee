parseArgs = require './parseArgs'

module.exports = (containerID, options) ->
  defaults =
    welcome: ""
    prompt: ""
    separator: "&gt;"
    theme: "interlaced"

  options = options or defaults
  options.welcome = options.welcome or defaults.welcome
  options.prompt = options.prompt or defaults.prompt
  options.separator = options.separator or defaults.separator
  options.theme = options.theme or defaults.theme

  @subscribe = (callback) ->
    return

  @processCommand = (line) ->
    {cmd, args, line} = parseArgs line
    if cmd
      response = options.execute(cmd, args, term) if options.execute
      response = cmd + ": command not found"  if response is false
      output response

  @output = (str) =>
    if str and str.join
      @output line for line in str
    else
      console.log str
    return null

  @format = @f = require './formatting'

  prompt = (callback) ->
    stdin = process.stdin
    stdout = process.stdout

    stdin.resume()
    stdout.write '> '
  
    stdin.once 'data', (data) =>
      line = data.toString()
      @processCommand line
      callback()

  mainLoop = ->
    prompt ->
      mainLoop()

  mainLoop()

  term = this
  return term
