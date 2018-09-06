parseArgs = require './parseArgs'

module.exports = (containerID, options) ->
  
  # Create terminal and cache DOM nodes;
  # Hackery to resize the interlace background image as the container grows.
  # Works best with the scroll into view wrapped in a setTimeout.
  # Always force text cursor to end of input line.
  # Handle up/down key presses for shell history and enter for new command.

  inputTextClick = (e) ->
    @value = @value
    return
  historyHandler = (e) ->
    
    # Clear command-line on Escape key.
    if e.keyCode is 27
      @value = ""
      e.stopPropagation()
      e.preventDefault()
    if _history.length and (e.keyCode is 38 or e.keyCode is 40)
      if _history[_histpos]
        _history[_histpos] = @value
      else
        _histtemp = @value
      if e.keyCode is 38
        
        # Up arrow key.
        _histpos--
        _histpos = 0  if _histpos < 0
      else if e.keyCode is 40
        
        # Down arrow key.
        _histpos++
        _histpos = _history.length  if _histpos > _history.length
      @value = (if _history[_histpos] then _history[_histpos] else _histtemp)
      
      # Move cursor to end of input.
      @value = @value
    return

  addToHistory = (_history, newEntry) ->
    
    # Remove repeated history entries
    if newEntry of _historySet
      i = _history.length - 1

      while i >= 0
        if _history[i] is newEntry
          _history.splice i, 1
          break
        i--
    _history.push newEntry
    _historySet[newEntry] = true
    return

  newCommandHandler = (e) ->
    
    # Only handle the Enter key.
    return  unless e.keyCode is 13
    cmdline = @value
    
    # Save shell history.
    if cmdline
      addToHistory _history, cmdline
      localStorage["history"] = JSON.stringify(_history)
      localStorage["historySet"] = JSON.stringify(_historySet)
      _histpos = _history.length
    
    # Duplicate current input and append to output section.
    line = @parentNode.parentNode.parentNode.parentNode.cloneNode(true)
    line.removeAttribute "id"
    line.classList.add "line"
    input = line.querySelector("input.cmdline")
    input.autofocus = false
    input.readOnly = true
    input.insertAdjacentHTML "beforebegin", input.value
    input.parentNode.removeChild input
    _output.appendChild line
    
    # Hide command line until we're done processing input.
    _inputLine.classList.add "hidden"
    
    # Clear/setup line for next input.
    @value = ""
    
    {cmd, args, line} = parseArgs cmdline
    
    # Notify event listeners
    args = args or []
    i = 0
    while i < _cmdListeners.length
      listener = _cmdListeners[i]
      listener args  if typeof listener is "function"
      i++

    if cmd
      response = options.execute(cmd, args, term) if options.execute
      response = cmd + ": command not found"  if response is false
      output response
    
    # Show the command line.
    _inputLine.classList.remove "hidden"
    return

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

  _history = (if localStorage.history then JSON.parse(localStorage.history) else [])
  _historySet = (if localStorage.historySet then JSON.parse(localStorage.historySet) else [])
  _histpos = _history.length
  _histtemp = ""
  _terminal = document.getElementById(containerID)
  _terminal.classList.add "terminal"
  _terminal.classList.add "terminal-" + options.theme
  _terminal.insertAdjacentHTML "beforeEnd", [
    "<div class=\"background\"><div class=\"interlace\"></div></div>"
    "<div class=\"container\">"
    "<output></output>"
    "<table class=\"input-line\">"
    "<tr><td nowrap><div class=\"prompt\">" + options.prompt + options.separator + "</div></td><td width=\"100%\"><input class=\"cmdline\" autofocus /></td></tr>"
    "</table>"
    "</div>"
  ].join("")
  _container = _terminal.querySelector(".container")
  _inputLine = _container.querySelector(".input-line")
  _cmdLine = _container.querySelector(".input-line .cmdline")
  _output = _container.querySelector("output")
  _prompt = _container.querySelector(".prompt")
  _background = document.querySelector(".background")
  _cmdListeners = []
  _output.addEventListener "DOMSubtreeModified", ((e) ->
    setTimeout (->
      _cmdLine.scrollIntoView()
      return
    ), 0
    return
  ), false
  output options.welcome  if options.welcome
  window.addEventListener "click", ((e) ->
    _cmdLine.focus()
    return
  ), false
  _output.addEventListener "click", ((e) ->
    e.stopPropagation()
    return
  ), false
  _cmdLine.addEventListener "click", inputTextClick, false
  _inputLine.addEventListener "click", ((e) ->
    _cmdLine.focus()
    return
  ), false
  _cmdLine.addEventListener "keyup", historyHandler, false
  _cmdLine.addEventListener "keydown", newCommandHandler, false
  window.addEventListener "keyup", ((e) ->
    _cmdLine.focus()
    e.stopPropagation()
    e.preventDefault()
    return
  ), false
  @processCommand = (line) ->
    _cmdLine.value = line
    e = new Event("keydown")
    e.keyCode = 13
    _cmdLine.dispatchEvent e
    return

  @subscribe = (callback) ->
    _cmdListeners.push callback
    return

  @clear = ->
    _output.innerHTML = ""
    _cmdLine.value = ""
    _background.style.minHeight = ""
    return

  output = (html) ->
    if html.join
      output line for line in html
    else if typeof html == 'string'
      html = "<div class='line'>#{html}</div>"
      _output.insertAdjacentHTML "beforeEnd", html
      _cmdLine.scrollIntoView()
      return
  @output = output

  @format = @f = require './formatting'

  @setPrompt = (prompt) ->
    _prompt.innerHTML = prompt + options.separator
    return

  @getPrompt = ->
    _prompt.innerHTML.replace new RegExp(options.separator + "$"), ""

  @setTheme = (theme) ->
    _terminal.classList.remove "terminal-" + options.theme
    options.theme = theme
    _terminal.classList.add "terminal-" + options.theme
    return

  @getTheme = ->
    options.theme

  term = this
  return term
