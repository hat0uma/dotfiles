local M = {
  "stevearc/conform.nvim",
}

local format_disable_clients = {
  "tsserver",
  "lua_ls",
}

vim.g.format_on_save_enabled = true
vim.g.format_on_save_mode = "Buffer" --- @type "Hunks"|"Buffer"

--- lsp filter function
---@param client vim.lsp.Client
---@return boolean
local function filter(client)
  return not vim.tbl_contains(format_disable_clients, client.name)
end

--- format hunks async
---@param bufnr integer
---@param callback function
local function format_hunks(bufnr, callback)
  local hunks = require("gitsigns").get_hunks()
  hunks = vim.tbl_filter(function(hunk)
    return hunk.type == "add" or hunk.type == "change"
  end, hunks)

  local do_format ---@type function
  do_format = function(idx, hunk)
    if not hunk then
      callback()
      return
    end
    local start_line = hunk.added.start
    local end_line = hunk.added.start + hunk.added.count - 1
    local range = {
      ["start"] = { start_line, 0 },
      ["end"] = { end_line, vim.fn.col({ end_line, "$" }) - 2 },
    }
    require("conform").format({
      bufnr = bufnr,
      async = true,
      lsp_fallback = "always",
      filter = filter,
      range = range,
    }, function()
      do_format(next(hunks, idx))
    end)
  end
  do_format(next(hunks))
end

function M.save_handle()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.g.format_on_save_enabled then
    vim.cmd.write()
    return
  end
  if vim.g.format_on_save_mode == "Buffer" then
    require("conform").format({
      bufnr = bufnr,
      async = true,
      lsp_fallback = "always",
      filter = filter,
    }, function(err)
      if err then
        -- vim.notify(err)
      end
      vim.cmd.write()
    end)
  else
    format_hunks(bufnr, function(err)
      if err then
        vim.notify(err)
      end
      vim.cmd.write()
    end)
  end
end

local formatter_for_ts = function(bufnr)
  local deno = vim.lsp.get_clients({ bufnr = bufnr, name = "denols" })
  if #deno > 0 then
    return {} -- deno lsp has its own formatter
  else
    return { "prettierd", "prettier", stop_after_first = true }
  end
end

M.config = function()
  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylua" },
      typescript = formatter_for_ts,
      typescriptreact = formatter_for_ts,
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      json = { "fixjson" },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "markdownlint-cli2" },
      sh = { "shfmt" },
    },
  })

  vim.api.nvim_create_user_command("FormatOnSaveMode", function(opts)
    if #opts.fargs == 0 then
      print(vim.g.format_on_save_mode)
    else
      vim.g.format_on_save_mode = opts.fargs[1]
    end
  end, {
    nargs = "?",
    complete = function(arg_lead, _, _)
      return vim.tbl_filter(function(item)
        return vim.startswith(item, arg_lead)
      end, { "Buffer", "Hunks" })
    end,
  })
  vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
    vim.g.format_on_save_enabled = not vim.g.format_on_save_enabled
  end, {})
  vim.api.nvim_create_user_command("FormatOnSaveDisable", function()
    vim.g.format_on_save_enabled = false
  end, {})
  vim.api.nvim_create_user_command("FormatOnSaveEnable", function()
    vim.g.format_on_save_enabled = true
  end, {})
  vim.api.nvim_create_user_command("Format", function()
    local bufnr = vim.api.nvim_get_current_buf()
    require("conform").format({
      bufnr = bufnr,
      async = true,
      lsp_fallback = "always",
      filter = filter,
    })
  end, {})
end

return M
