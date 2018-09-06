module.exports = ( ->
  if typeof window != 'undefined' and window.document
    css = require './lib/terminal.css'
    insertCSS = require 'insert-css'
    insertCSS css
    return require './lib/browser'
  else
    return require './lib/console'
)()
