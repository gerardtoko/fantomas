hashids = require 'hashids'

module.exports =
  format: (str, args) ->
    return str.replace '{0}', args if {}.toString.call(args) is '[object String]'

    if {}.toString.call(args) is '[object Array]'
      return str.replace new RegExp('{-?[0-9]+}', 'g'), (item) ->
        intVal = parseInt item.substring(1, item.length - 1)
        if (intVal >= 0)
          if args[intVal]
            return args[intVal]
          else
            return '{' + intVal + '}'
        else if (intVal is -1)
          return '{'
        else if (intVal is -2)
          return '}'
        else
          return ''

    if {}.toString.call(args) is '[object Object]'
      for key, value of args
        str = str.replace '\{' + key + '\}', value
      return str

  hash: (str) ->
    hashid = new hashids str
    hashid.encrypt 1, 2, 3, 4, 5, 6, 7, 8, 9, 10