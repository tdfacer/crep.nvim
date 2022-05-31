local Job = require 'plenary.job'

local actions = require 'telescope.actions'
local actions_set = require 'telescope.actions.set'
local actions_state = require 'telescope.actions.state'
local conf = require 'telescope.config'.values
local entry_display = require 'telescope.pickers.entry_display'
local finders = require 'telescope.finders'
local Path = require("plenary.path")
local pickers = require 'telescope.pickers'
local previewers = require 'telescope.previewers.term_previewer'
local utils = require 'telescope.utils'
local defaulter = utils.make_default_callable

local _M = {}

local gh_previewer = defaulter(function(opts)
  vim.pretty_print(opts)
  opts = opts or {}

  return previewers.new_termopen_previewer {
    title = _M.organization .. " repo",

    get_command = function(entry)
      return { "echo", string.format("# %s", entry.name), string.format("\n\n* description: %s", entry.description), string.format("\n\n* pushed_at: %s", entry.pushed_at), string.format("\n\n* updated_at: %s", entry.updated_at), string.format("\n\n* pull_requests: %s", entry.pull_requests.totalCount) }
    end
  }
end, {})

_M.clone_repo = function(opts)
  Job:new({
    command = 'gh',
    args = { 'repo', 'clone', string.format("%s/%s", opts.organization, opts.repo), '--', string.format("%s/%s", _M.destination_dir, opts.repo) },
    on_exit = function(_, return_val)
      if return_val > 0 then
        print("failed to clone: " .. opts.repo)
        return {}
      else
        print("successfully cloned: " .. opts.repo)
        return {}
      end
    end,
  }):sync()
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
    }
  end

  return function(result)
    return {
      display = make_display,
      value = string.format("%s/%s", _M.destination_dir, result.name),
      name = result.name,
      ordinal = result.name,
      description = result.description,
      pushed_at = result.pushedAt,
      updated_at = result.updatedAt,
      pull_requests = result.pullRequests,
    }
  end
end

_M.get_repos = function(opts)
  opts = opts or _M.opts
  opts.cwd = utils.get_lazy_default(opts.cwd, vim.loop.cwd)
  opts.entry_maker = utils.get_lazy_default(
    opts.entry_maker,
    gen_from_gh_repo_list,
    opts
  )

  local all_results = {}

  local res_path = Path:new { "/tmp/repo_list.json" }
  if not res_path:exists() then
    print("temp file does not exist yet at " .. _M.temp_file)
  else
    local fh = io.open("/tmp/repo_list.json")
    if fh ~= nil then
      all_results = vim.json.decode(fh:read("*a"))
    end
  end

  print("refreshing repo list, please wait(0)...")
  if #all_results <= 0 then
    Job:new({
      command = 'gh',
      args = { 'repo', 'list', _M.organization, "-L", "1000", '--json', 'name,description,pushedAt,updatedAt,pullRequests' },
      on_start = function()
        print("refreshing repo list, please wait(1)...")
      end,
      on_exit = function(j, return_val)
        if return_val > 0 then
          print("failed to complete command with error code: " .. return_val)
          return {}
        end

        local result = j:result()

        local _, results = pcall(vim.json.decode, table.concat(result, ""))

        for _, v in pairs(results) do
          table.insert(all_results, v)
        end

        local fh = io.open("/tmp/repo_list.json", "w+")
        if fh ~= nil then
          fh:write(vim.json.encode(all_results))
          fh:close()
        end
      end,
    }):sync(30000) -- or start()
    print("refreshing repo list, please wait(2)...")
  end

  pickers.new(opts, {
    prompt_title = 'github repos',
    finder = finders.new_table {
      results = all_results,
      entry_maker = opts.entry_maker,
    },
    sorter = conf.generic_sorter(),
    previewer = gh_previewer:new(actions_state.get_selected_entry()),
    attach_mappings = function(prompt_bufnr)
      actions_set.select:replace(function(_, type)
        local entry = actions_state.get_selected_entry()
        local path = Path:new { "/home/trevor/code", entry.name }
        if not path:exists() then
          print(entry.name .. " does not exist from org " .. _M.organization)
          _M.clone_repo({ organization = _M.organization, repo = entry.name })
        else
          print(entry.name .. " exists")
        end
        vim.cmd('cd ' .. _M.destination_dir .. "/" .. entry.name)
        actions.close(prompt_bufnr)
        vim.cmd('Telescope fd')
      end)
      return true
    end,
  }):find()
end

return _M
