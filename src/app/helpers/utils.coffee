_ = require('lodash')
hashids = require 'hashids'

String::trimLeft = (charlist) ->
  charlist = "\s" if charlist is undefined;
  @replace new RegExp("^[" + charlist + "]+"), ""

String::trimRight = (charlist) ->
  charlist = "\s" if charlist is undefined;
  @replace new RegExp("[" + charlist + "]+$"), ""

String::trim = (charlist) ->
  return @trimLeft(charlist).trimRight(charlist);

String::format = (args) ->
  str = @
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
  @charAt(0).toUpperCase() + @slice 1;

String::hash = () ->
  hashid = new hashids @
  hashid.encrypt 1, 2, 3, 4, 5, 6, 7, 8, 9, 10


module.exports =
  format: (str, args) ->
    str.format args