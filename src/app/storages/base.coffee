
module.exports =
  get: (name) ->
    require("./#{name}").getInstance()