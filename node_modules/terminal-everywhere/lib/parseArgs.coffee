module.exports = (line) ->
  cmd = ''
  args = []
  # Parse out command, args, and trim off whitespace.
  if line and line.trim()
    provArgs = line.split(" ")
    
    # Parse quotes ['"]
    realArgs = []
    arg = ""
    provArgs.join(" ").split("").forEach (letter) ->
      if letter is " "
        if arg.length
          if arg[0] isnt "\"" and arg[0] isnt "'"
            realArgs.push arg
            arg = ""
          else
            arg += letter
      else if letter is "\"" or letter is "'"
        if arg.length and arg[0] is letter
          realArgs.push arg.slice(1)
          arg = ""
        else
          arg += letter
      else
        arg += letter
      return

    realArgs.push arg.trim() # add what is at the end
    
    # Filter empty
    args = realArgs
    args = args.filter (val, i) ->
      val

    cmd = args[0] # Get cmd.
    args = args.splice(1) # Remove cmd from arg list.

  return {
    cmd: cmd.trim()
    args: args
    line: line
  }
