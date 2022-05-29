local Job = require 'plenary.job'
local Job = require 'plenary.job'


-- name,description,pushedAt
-- use this to get list of json fields:
-- gh repo list --json 2>&1 | v -

Job:new({
  command = 'gh',
  args = { 'repo', 'list', '--json', 'name,description,pushedAt' },
  -- cwd = '/home/trevor/code/opsgenie-ts',
  -- cwd = '/usr/bin',
  -- env = { ['a'] = 'b' },
  on_exit = function(j, return_val)
    -- print(return_val)
    -- print(type(return_val))
    -- if return_val > 0 or return_val ~= "0" then
    --   print("failed to complete command with error code: " .. return_val)
    -- end
    if return_val > 0 then
      print("failed to complete command with error code: " .. return_val)
      -- print("failed to complete command with error code: " .. return_val .. "; " .. j)
      -- print("err: " .. j)
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
      print(string.format("parsed key: %s, val: %s", k, vim.inspect(v)))
    end


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
