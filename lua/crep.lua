local Job = require 'plenary.job'

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
