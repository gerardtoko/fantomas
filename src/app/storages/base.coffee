U = require './../helpers/utils'

module.exports =
  get: (name) ->
    require(U.format './{0}', [name]).getInstance()