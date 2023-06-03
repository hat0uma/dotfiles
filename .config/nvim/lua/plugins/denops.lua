local M = {
  "vim-denops/denops.vim",
}

local deno_executable = vim.fn.expand "~/.deno/bin/deno"
function M.config()
  if vim.fn.executable "deno" ~= 1 then
    vim.g["denops#deno"] = deno_executable
  end

  if vim.fn.has "vim_starting" == 1 then
    vim.fn["denops#server#start"]()
  end
end

setmetatable(M, {
  __index = {
    register = function(name)
      --- @type string
      local status = vim.fn["denops#server#status"]()
      if status == "running" then
        vim.fn["denops#plugin#register"](name, { mode = "skip" })
        vim.fn["denops#plugin#wait"](name)
      else
        vim.api.nvim_create_autocmd("User", {
          pattern = "DenopsReady",
          once = true,
          callback = function()
            vim.fn["denops#plugin#register"](name, { mode = "skip" })
            vim.fn["denops#plugin#wait"](name)
          end,
        })
      end
    end,
    --- @param name string
    ---@return string
    cache = function(name)
      return string.format("%s cache ./denops/%s/main.ts", deno_executable, name)
    end,
  },
})

return M
