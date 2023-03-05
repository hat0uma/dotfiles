local M = {
  "vim-denops/denops.vim",
}

function M.config()
  if vim.fn.executable "deno" ~= 1 then
    vim.g["denops#deno"] = vim.fn.expand "~/.deno/bin/deno"
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
    cache = function(name)
      return string.format("deno cache ./denops/%s/main.ts", name)
    end,
  },
})

return M
