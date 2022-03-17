local M = {}

function M.wait_ready()
  local status = vim.fn["denops#server#status"]()
  if status == "running" then
    return
  end

  if status == "stoppped" then
    vim.fn["denops#server#start"]()
  end

  local success, err = vim.wait(1000, function()
    return vim.fn["denops#server#status"]() == "running"
  end, 1)

  if not success then
    print(string.format("timeout waiting denops#server#start err=%d", err))
  end
end

function M.register(name)
  vim.fn["denops#plugin#register"](name, { mode = "skip" })
  vim.fn["denops#plugin#wait"](name)
  -- print("denops plugin " .. name .. " is loaded")
end

return M
