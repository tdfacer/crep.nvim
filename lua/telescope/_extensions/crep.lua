local crep = require 'telescope._extensions.crep.crep'

return require 'telescope'.register_extension {
  exports = {
    get_repos = crep.get_repos,
  },
}
