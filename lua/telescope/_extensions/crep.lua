local crep = require 'telescope._extensions.crep.crep'

return require 'telescope'.register_extension {
  setup = function(ext_config)
    crep.organization = ext_config.organization
    crep.destination_dir = "/home/trevor/code"
    crep.temp_file = "/tmp/repo_list.json"
  end,
  exports = {
    get_repos = crep.get_repos,
    setup = crep.setup,
  },
}
