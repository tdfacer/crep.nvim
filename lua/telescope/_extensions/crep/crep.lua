local Job = require 'plenary.job'

-- local actions = require'telescope.actions'
-- local actions_set = require'telescope.actions.set'
-- local actions_state = require'telescope.actions.state'
-- local conf = require'telescope.config'.values
local entry_display = require 'telescope.pickers.entry_display'
-- local finders = require'telescope.finders'
-- local from_entry = require'telescope.from_entry'
-- local Path = require("plenary.path")
-- local pickers = require'telescope.pickers'
-- local previewers = require'telescope.previewers.term_previewer'
-- local utils = require'telescope.utils'


-- name,description,pushedAt
-- use this to get list of json fields:
-- gh repo list --json 2>&1 | v -

local _M = {}

_M.setup = function(opts)
  _M.organization = opts.organization or ""
end

_M.do_stuff = function()
  print("doing stuff!")
end

local function gen_from_gh_repo_list(opts)
  local displayer = entry_display.create {
    separator = ' ',
    items = {
      {}, -- name
      {}, -- description
      {}, -- pushed_at
    },
  }

  local function make_display(entry)
    return displayer {
      entry.name,
      { '(' .. entry.description .. ')', 'TelescopeResultsIdentifier' },
      { entry.pushed_at and '[' .. entry.pushed_at .. ']' or '', 'TelescopeResultsComment' },
      -- {'('..entry.version..')', 'TelescopeResultsIdentifier'},
      -- {entry.level and '['..entry.level..']' or '', 'TelescopeResultsComment'},
    }
  end

  return function(result)
    return {
      display = make_display,
      -- level = result.level,
      name = result.name,
      -- ordinal = result.json.name,
      -- path = result.dir,
      description = result.description,
      pushed_at = result.pushedAt,
    }
  end
end

_M.get_repos = function()
  Job:new({
    command = 'gh',
    -- args = { 'repo', 'list', _M.organization, '--json', 'name,description,pushedAt' },
    args = { 'repo', 'list', _M.organization, '--json', 'name,description,pushedAt' },
    -- cwd = '/home/trevor/code/opsgenie-ts',
    -- cwd = '/usr/bin',
    -- env = { ['a'] = 'b' },
    on_exit = function(j, return_val)
      if return_val > 0 then
        print("failed to complete command with error code: " .. return_val)
        return {}
      else
        print(vim.inspect(j:result()))
      end

      local result = j:result()

      local ok, parsed = pcall(vim.json.decode, table.concat(result, ""))

      if not ok then
        print("was not ok. ok: " .. ok)
      else
        -- print("ok! ok: " .. ok)
        string.format("ok!: ok: %s", ok)
      end

      if not parsed then
        print("was not parsed. parsed: " .. parsed)
      else
        -- print("parsed! parsed: " .. parsed)
        string.format("parsed! parsed: %parsed", parsed)
      end

      for k, v in pairs(parsed) do
        -- print(string.format("parsed key: %s, val: %s", k, vim.inspect(v)))
        print("name: " .. v.name)
        print("description: " .. v.description)
        print("pushedAt: " .. v.pushedAt)
      end

      -- local newbuf = vim.api.nvim_create_buf(false, true)

      -- vim.api.nvim_open_term()

      -- for k, v in ipairs(j:result()) do
      --   print(k)
      -- end

      -- print(vim.inspect(return_val))
      -- print(vim.inspect(j:result()))
    end,
    -- on_error = function(e, res)
    --   print("error: " .. e)
    --   print("res: " .. res)
    -- end,
    -- }):sync() -- or start()
  }):start() -- or start()
end

_M.setup({
  organization = "ifit",
})
_M.do_stuff()
_M.get_repos()

return _M

-- local actions = require'telescope.actions'
-- local actions_set = require'telescope.actions.set'
-- local actions_state = require'telescope.actions.state'
-- local conf = require'telescope.config'.values
-- local entry_display = require'telescope.pickers.entry_display'
-- local finders = require'telescope.finders'
-- local from_entry = require'telescope.from_entry'
-- local Path = require("plenary.path")
-- local pickers = require'telescope.pickers'
-- local previewers = require'telescope.previewers.term_previewer'
-- local utils = require'telescope.utils'
--
-- local M = {}
--
-- local function gen_from_node_modules(opts)
--   local displayer = entry_display.create{
--     separator = ' ',
--     items = {
--       {}, -- name
--       {}, -- version
--       {}, -- level
--     },
--   }
--
--   local function make_display(entry)
--     return displayer{
--       entry.name,
--       {'('..entry.version..')', 'TelescopeResultsIdentifier'},
--       {entry.level and '['..entry.level..']' or '', 'TelescopeResultsComment'},
--     }
--   end
--
--   return function(result)
--     return {
--       display = make_display,
--       level = result.level,
--       name = result.json.name,
--       ordinal = result.json.name,
--       path = result.dir,
--       value = result.json.name,
--       version = result.json.version,
--     }
--   end
-- end
--
-- local function package_info(dir)
--   local path = Path:new{dir, "package.json"}
--   if not path:exists() then return nil end
--   local text = Path:new{dir, "package.json"}:read()
--   local ok, json = pcall(vim.fn.json_decode, text)
--   return ok and {dir = dir, json = json} or nil
-- end
--
-- local function dependencies(json)
--   local deps = {}
--   for key, level in pairs{
--     dependencies = 'prod',
--     devDependencies = 'dev',
--     peerDependencies = 'peer',
--     optionalDependencies = 'optional',
--   } do
--     local dep_map = json[key]
--     if dep_map then
--       for name, _ in pairs(dep_map) do
--         deps[name] = level
--       end
--     end
--   end
--   return deps
-- end
--
-- local function iter_dir(fn, dir)
--   local fd = vim.loop.fs_opendir(dir, nil, 10)
--   if not fd then return end
--   while true do
--     local fs_entries = vim.loop.fs_readdir(fd)
--     if not fs_entries then
--       break
--     end
--     vim.tbl_map(function(fs_entry)
--       if fs_entry.type == 'directory' then
--          fn(dir, fs_entry.name)
--       -- when using pnpm, node modules are symlinked
--       elseif fs_entry.type == 'link' then
--         local target = vim.loop.fs_readlink(dir .. '/'.. fs_entry.name)
--         local stat = vim.loop.fs_stat(dir .. '/'.. target)
--         if stat.type == 'directory' then
--           fn(dir, target)
--         end
--       end
--     end, fs_entries)
--   end
--   vim.loop.fs_closedir(fd)
-- end
--
-- M.list = function(opts)
--   opts = opts or {}
--   opts.cwd = utils.get_lazy_default(opts.cwd, vim.loop.cwd)
--   opts.entry_maker = utils.get_lazy_default(
--     opts.entry_maker,
--     gen_from_node_modules,
--     opts
--   )
--
--   local info = package_info(opts.cwd)
--   if not info then
--     vim.notify("package.json not found", vim.log.levels.WARN)
--     return
--   end
--   local deps = dependencies(info.json)
--
--   local function process_dir(results, dir)
--     local result = package_info(dir)
--     if result then
--       result.level = deps[result.json.name]
--       table.insert(results, result)
--     end
--   end
--
--   local results = {}
--   iter_dir(function(dir, base)
--     local fullpath = dir..'/'..base
--     if base:sub(1, 1) == '@' then
--       iter_dir(function(sub_dir, sub_base)
--          process_dir(results, sub_dir..'/'..sub_base)
--       end, fullpath)
--     else
--       process_dir(results, dir..'/'..base)
--     end
--   end, opts.cwd..'/node_modules')
--
--   pickers.new(opts, {
--     prompt_title = 'Packages from node_modules dir',
--     finder = finders.new_table{
--       results = results,
--       entry_maker = opts.entry_maker,
--     },
--     sorter = conf.file_sorter(opts),
--     previewer = previewers.cat.new(opts),
--     attach_mappings = function(prompt_bufnr)
--       actions_set.select:replace(function(_, type)
--         local entry = actions_state.get_selected_entry()
--         local dir = from_entry.path(entry)
--         print(dir)
--         if type == 'default' then
--           require'telescope.builtin'.find_files{cwd = dir, no_ignore = true}
--           return
--         end
--         actions.close(prompt_bufnr)
--         if type == 'horizontal' then
--           vim.cmd('cd '..dir)
--           print('chdir to '..dir)
--         elseif type == 'vertical' then
--           vim.cmd('lcd '..dir)
--           print('lchdir to '..dir)
--         elseif type == 'tab' then
--           vim.cmd('tcd '..dir)
--           print('tchdir to '..dir)
--         end
--       end)
--       return true
--     end,
--   }):find()
-- end
--
-- return M
