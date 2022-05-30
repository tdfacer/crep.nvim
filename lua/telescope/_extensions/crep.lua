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
-- return require('telescope').register_extension {
--   setup = function(ext_config)
--     filetypes = ext_config.filetypes or {"png", "jpg", "gif", "mp4", "webm", "pdf"}
--     find_cmd = ext_config.find_cmd or "fd"
--   end,
--   exports = {
--     media_files = M.media_files
--   },
-- }
--
-- telescope.setup {
--   extensions = {
--     frecency = {
--       db_root = "home/my_username/path/to/db_root",
--       show_scores = false,
--       show_unindexed = true,
--       ignore_patterns = {"*.git/*", "*/tmp/*"},
--       disable_devicons = false,
--       workspaces = {
--         ["conf"]    = "/home/my_username/.config",
--         ["data"]    = "/home/my_username/.local/share",
--         ["project"] = "/home/my_username/projects",
--         ["wiki"]    = "/home/my_username/wiki"
--       }
--     }
--   },
-- }
