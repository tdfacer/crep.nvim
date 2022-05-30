local crep = require 'telescope._extensions.crep.crep'

return require 'telescope'.register_extension {
  setup = function(ext_config)
    crep.organization = ext_config.organization
    crep.destination_dir = "/home/trevor/code"
  end,
  exports = {
    get_repos = crep.get_repos,
  },
}
