local Job = require 'plenary.job'

local actions = require 'telescope.actions'
local actions_set = require 'telescope.actions.set'
local actions_state = require 'telescope.actions.state'
local conf = require 'telescope.config'.values
local entry_display = require 'telescope.pickers.entry_display'
local finders = require 'telescope.finders'
local from_entry = require 'telescope.from_entry'
local Path = require("plenary.path")
local pickers = require 'telescope.pickers'
local previewers = require 'telescope.previewers.term_previewer'
local utils = require 'telescope.utils'

-- name,description,pushedAt
-- use this to get list of json fields:
-- gh repo list --json 2>&1 | v -

local _M = {}

-- _M.state = {
--   organization = "",
--   destination_dir = "/tmp",
--   results = {},
-- }

_M.clone_repo = function(opts)
  print(string.format("cloning %s/%s", opts.organization, opts.repo))
  -- gh repo clone ifit/lycan -- /tmp/lycan
  Job:new({
    command = 'gh',
    args = { 'repo', 'clone', string.format("%s/%s", opts.organization, opts.repo), '--', string.format("%s/%s", _M.destination_dir, opts.repo) },
    on_exit = function(_, return_val)
      if return_val > 0 then
        print("failed to clone: " .. opts.repo)
        return {}
      else
        print("successfully cloned: " .. opts.repo)
        -- vim.cmd('cd ' .. _M.destination_dir .. "/" .. opts.repo)
        return {}
      end
    end,
  }):sync() -- or start()
end

_M.setup = function(opts)
  vim.pretty_print(opts)
  _M.organization = opts.organization and opts.organization or ""
  _M.destination_dir = opts.destination_dir and opts.destination_dir or "/tmp/"
  _M.temp_file = "/tmp/repo_list.json"
  return _M
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
      { entry.description and '(' .. entry.description .. ')' or "default", 'TelescopeResultsIdentifier' },
      { entry.pushed_at and '[' .. entry.pushed_at .. ']' or '', 'TelescopeResultsComment' },
      -- {'('..entry.version..')', 'TelescopeResultsIdentifier'},
      -- {entry.level and '['..entry.level..']' or '', 'TelescopeResultsComment'},
    }
  end

  return function(result)
    return {
      display = make_display,
      value = result.name,
      name = result.name,
      ordinal = result.name,
      description = result.description,
      pushed_at = result.pushedAt,
    }
  end
end

local function print_info()
  print(string.format("organization: %s", _M.organization))
  print(string.format("destination_dir: %s", _M.destination_dir))
  print(string.format("temp_file: %s", _M.temp_file))
end

_M.get_repos = function(opts)
  print_info()
  opts = opts or _M.opts
  opts.cwd = utils.get_lazy_default(opts.cwd, vim.loop.cwd)
  opts.entry_maker = utils.get_lazy_default(
    opts.entry_maker,
    gen_from_gh_repo_list,
    opts
  )
  -- local all_results = temp_repos
  -- local format = gen_from_gh_repo_list()
  -- local first = all_results[1]
  -- local check = format(first)
  -- vim.pretty_print(check)

  local all_results = {}

  print_info()
  -- local res_path = Path:new { _M.temp_file }
  local res_path = Path:new { "/tmp/repo_list.json" }
  if not res_path:exists() then
    print("temp file does not exist yet at " .. _M.temp_file)
  else
    local fh = io.open("/tmp/repo_list.json")
    if fh ~= nil then
      all_results = vim.json.decode(fh:read("*a"))
    end
  end

  if #all_results <= 0 then
    Job:new({
      command = 'gh',
      args = { 'repo', 'list', _M.organization, '--json', 'name,description,pushedAt' },
      -- timeout = 30000,
      on_exit = function(j, return_val)
        if return_val > 0 then
          print("failed to complete command with error code: " .. return_val)
          return {}
        end

        local result = j:result()

        local ok, results = pcall(vim.json.decode, table.concat(result, ""))
        -- vim.json.encode

        if not ok then
          print("was not ok. ok: " .. ok)
        else
          string.format("ok!: ok: %s", ok)
        end

        if not results then
          print("was not parsed. parsed: " .. results)
        else
          string.format("parsed! parsed: %parsed", results)
        end

        -- save results to a json file
        -- local fh = io.open(_M.temp_file, "w")
        local fh = io.open("/tmp/repo_list.json", "w")
        if fh ~= nil then
          fh:write(vim.json.encode(result))
          fh:close()
        end
        -- temp_file

        for _, v in pairs(results) do
          table.insert(all_results, v)
        end
      end,
    }):sync(5000) -- or start()
    -- }):sync(60000) -- or start()
  end
  -- }):start() -- or start()

  pickers.new(opts, {
    prompt_title = 'github repos',
    finder = finders.new_table {
      -- results = { { name = "Trevor", description = "description", pushedAt = "something" } },
      results = all_results,
      entry_maker = opts.entry_maker,
    },
    sorter = conf.generic_sorter(),
    previewer = previewers.cat.new(opts),
    -- previewer = previewers.vim_buffer_cat.new(opts),
    attach_mappings = function(prompt_bufnr)
      actions_set.select:replace(function(_, type)
        local entry = actions_state.get_selected_entry()

        -- print(entry.name)
        -- local desired_path = "~/code/" .. entry.name
        local path = Path:new { "/home/trevor/code", entry.name }
        if not path:exists() then
          print(entry.name .. " does not exist from org " .. _M.organization)
          _M.clone_repo({ organization = _M.organization, repo = entry.name })
        else
          print(entry.name .. " exists")
        end
        vim.cmd('cd ' .. _M.destination_dir .. "/" .. entry.name)
        -- if not path:exists() then return nil end
        --       local exists = path:exists()
        -- local dir = from_entry.path(entry)
        -- print(dir)
        -- if type == 'default' then
        --   require 'telescope.builtin'.find_files { cwd = dir, no_ignore = true }
        --   return
        -- end
        actions.close(prompt_bufnr)
        -- if type == 'horizontal' then
        --   vim.cmd('cd ' .. dir)
        --   print('chdir to ' .. dir)
        -- elseif type == 'vertical' then
        --   vim.cmd('lcd ' .. dir)
        --   print('lchdir to ' .. dir)
        -- elseif type == 'tab' then
        --   vim.cmd('tcd ' .. dir)
        --   print('tchdir to ' .. dir)
        -- end
      end)
      return true
    end,
  }):find()
end

return _M
