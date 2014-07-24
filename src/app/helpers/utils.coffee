_ = require('lodash')
hasOwnProperty = Object.prototype.hasOwnProperty

module.exports =
  format: (str, args) ->
    String.prototype.format = (args) ->
      _str = this
      return _str.replace String.prototype.format.regex, (item) ->
        intVal = parseInt item.substring(1, item.length - 1)
        if (intVal >= 0)
          args[intVal]
        else if (intVal is -1)
          "{"
        else if (intVal is -2)
          "}"
        else
          ""
    String.prototype.format.regex = new RegExp "{-?[0-9]+}", "g"
    str.format args
  capitaliseFirstLetter: (string) ->
      string.charAt(0).toUpperCase() + string.slice 1;