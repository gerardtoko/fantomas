_ = require('lodash')

String::trimLeft = (charlist) ->
  charlist = "\s" if charlist is undefined;
  this.replace new RegExp("^[" + charlist + "]+"), ""

String::trimRight = (charlist) ->
  charlist = "\s" if charlist is undefined;
  this.replace new RegExp("[" + charlist + "]+$"), ""

String::trim = (charlist) ->
  return this.trimLeft(charlist).trimRight(charlist);

String::format = (args) ->
  str = this
  str.replace String::format.regex, (item) ->
    intVal = parseInt item.substring(1, item.length - 1)
    if (intVal >= 0)
      args[intVal]
    else if (intVal is -1)
      "{"
    else if (intVal is -2)
      "}"
    else
      ""
String::format.regex = new RegExp "{-?[0-9]+}", "g"

String::title = () ->
  this.charAt(0).toUpperCase() + this.slice 1;


module.exports =
  format: (str, args) ->
    str.format args