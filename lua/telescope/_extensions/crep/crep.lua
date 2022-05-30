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

-- local organization = ""
-- local destination_dir = ""

local temp_repos = {
  {
    description = "Quick start repository for creating a Terraform provider",
    name = "terraform-provider-scaffolding",
    pushedAt = "2022-05-24T07:00:36Z"
  },
  {
    description = "",
    name = "tdfacer.github.io",
    pushedAt = "2022-05-23T00:13:44Z"
  },
  {
    description = "",
    name = "ifit-static-test",
    pushedAt = "2022-04-16T20:11:41Z"
  },
  {
    description = "",
    name = "cloudops",
    pushedAt = "2022-04-15T23:16:14Z"
  },
  {
    description = "Save Our Summer (SOS): A family bucket list application",
    name = "sos",
    pushedAt = "2022-04-09T03:16:05Z"
  },
  {
    description = "Terraform and Cloudformaton IaC",
    name = "terrafacer",
    pushedAt = "2022-03-14T15:30:25Z"
  },
  {
    description = "",
    name = "family-goals-frontend",
    pushedAt = "2022-03-03T01:02:31Z"
  },
  {
    description = "",
    name = "spot-checker",
    pushedAt = "2022-01-27T01:21:22Z"
  },
  {
    description = "",
    name = "brightcove-deprecation",
    pushedAt = "2022-01-14T23:11:37Z"
  },
  {
    description = "",
    name = "family-goals",
    pushedAt = "2022-01-01T18:32:53Z"
  },
  {
    description = "",
    name = "family-goals-service",
    pushedAt = "2022-01-01T18:20:07Z"
  },
  {
    description = "hello world for graphql with typescript",
    name = "typescript-graphql",
    pushedAt = "2021-12-26T23:07:51Z"
  },
  {
    description = "",
    name = "opsgenie-alarms-2",
    pushedAt = "2021-12-23T16:46:57Z"
  },
  {
    description = "",
    name = "maizey_math",
    pushedAt = "2021-10-24T14:29:26Z"
  },
  {
    description = "",
    name = "2021_09_07_incident_response",
    pushedAt = "2021-09-21T22:53:31Z"
  },
  {
    description = "PKGBUILD for maintaining Aliyun CLI package in AUR",
    name = "aliyun-cli-bin",
    pushedAt = "2021-05-14T14:03:53Z"
  },
  {
    description = " =house_with_garden: Open source home automation that puts local control and privacy first",
    name = "core",
    pushedAt = "2021-03-19T17:25:19Z"
  },
  {
    description = "",
    name = "consciousness",
    pushedAt = "2021-03-14T18:48:18Z"
  },
  {
    description = "",
    name = "mqttjs",
    pushedAt = "2021-03-04T15:27:25Z"
  },
  {
    description = "",
    name = "mongo-terraform",
    pushedAt = "2021-01-23T17:04:07Z"
  },
  {
    description = "",
    name = "schedules",
    pushedAt = "2021-01-18T03:14:55Z"
  },
  {
    description = "",
    name = "devops",
    pushedAt = "2020-12-05T16:51:09Z"
  },
  {
    description = "",
    name = "covid-care-kits",
    pushedAt = "2020-10-31T16:45:27Z"
  },
  {
    description = "",
    name = "brightcove-tests",
    pushedAt = "2020-10-29T05:00:35Z"
  },
  {
    description = "Command-line program to download videos from YouTube.com and other video sites ",
    name = "youtube-dl",
    pushedAt = "2020-10-25T11:29:05Z"
  },
  {
    description = "",
    name = "xmlbuilder",
    pushedAt = "2020-09-09T04:56:35Z"
  },
  {
    description = "",
    name = "sandbox-elemental",
    pushedAt = "2020-07-27T21:18:10Z"
  },
  {
    description = "",
    name = "sos-static",
    pushedAt = "2020-07-27T13:39:41Z"
  },
  {
    description = "",
    name = "s3-handler",
    pushedAt = "2020-04-23T23:02:06Z"
  },
  {
    description = "",
    name = "nginx-wolf-updates",
    pushedAt = "2019-12-19T19:39:48Z"
  }
}

-- name,description,pushedAt
-- use this to get list of json fields:
-- gh repo list --json 2>&1 | v -

local _M = {}

_M.state = {
  organization = "",
  destination_dir = "/tmp"
}

-- local function set_config_state(opt_name, value, default)
--   state[opt_name] = value == nil and default or value
-- end

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
        vim.cmd('cd ' .. _M.destination_dir .. "/" .. opts.repo)
        return {}
      end
    end,
    -- on_stderr = function(err)
    --   print("err: " .. err)
    -- end
  }):start() -- or start()
end

_M.setup = function(opts)
  vim.pretty_print(opts)
  -- print("in setup, ops.organization: " .. opts.organization)
  _M.organization = opts.organization and opts.organization or ""
  _M.destination_dir = opts.destination_dir and opts.destination_dir or "/tmp/"
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
      -- level = result.level,
      name = result.name,
      ordinal = result.name,
      -- ordinal = result.json.name,
      -- path = result.dir,
      description = result.description,
      pushed_at = result.pushedAt,
    }
  end
end

function print_info()
  print(string.format("organization: %s", _M.organization))
  print(string.format("destination_dir: %s", _M.destination_dir))
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
  local all_results = temp_repos
  -- local format = gen_from_gh_repo_list()
  -- local first = all_results[1]
  -- local check = format(first)
  -- vim.pretty_print(check)

  -- local all_results = {}
  -- Job:new({
  --   command = 'gh',
  --   args = { 'repo', 'list', _M.organization, '--json', 'name,description,pushedAt' },
  --   on_exit = function(j, return_val)
  --     if return_val > 0 then
  --       print("failed to complete command with error code: " .. return_val)
  --       return {}
  --     else
  --       print(vim.inspect(j:result()))
  --     end
  --
  --     local result = j:result()
  --
  --     local ok, results = pcall(vim.json.decode, table.concat(result, ""))
  --
  --     if not ok then
  --       print("was not ok. ok: " .. ok)
  --     else
  --       -- print("ok! ok: " .. ok)
  --       string.format("ok!: ok: %s", ok)
  --     end
  --
  --     if not results then
  --       print("was not parsed. parsed: " .. results)
  --     else
  --       -- print("parsed! parsed: " .. parsed)
  --       string.format("parsed! parsed: %parsed", results)
  --     end
  --
  --     for _, v in pairs(results) do
  --       -- print(string.format("parsed key: %s, val: %s", k, vim.inspect(v)))
  --       -- print("name: " .. v.name)
  --       -- print("description: " .. v.description)
  --       -- print("pushedAt: " .. v.pushedAt)
  --       table.insert(all_results, v)
  --     end
  --   end,
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
          vim.cmd('cd ' .. _M.destination_dir .. "/" .. entry.name)
        end
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

-- _M.setup({
--   organization = "tdfacer",
--   -- organization = "",
--   -- organization = "ifit",
-- })

-- _M.do_stuff()
-- _M.get_repos()

return _M
