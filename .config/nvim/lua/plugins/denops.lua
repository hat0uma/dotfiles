local deno_executable = vim.fn.executable("deno") == 1 and "deno" or vim.fn.expand("~/.deno/bin/deno")
return {
  "vim-denops/denops.vim",
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
  config = function()
    vim.g["denops#deno"] = deno_executable

    if vim.fn.has("vim_starting") == 1 then
      vim.fn["denops#server#start"]()
    end
  end,
}
