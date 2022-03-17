local function accept(win)
  local new_name = vim.trim(vim.fn.getline ".")
  vim.api.nvim_win_close(win, true)
  vim.lsp.buf.rename(new_name)

  if vim.fn.mode() == "i" then
    vim.cmd [[stopinsert]]
  end
end

local function reject(win)
  vim.api.nvim_win_close(win, true)
end

local function rename()
  local opts = {
    relative = "cursor",
    row = 0,
    col = 0,
    width = 30,
    height = 1,
    style = "minimal",
    border = "single",
  }
  local cword = vim.fn.expand "<cword>"
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)
  local accept_fmt = '<cmd>lua require("rc.lsp.rename").accept(%d)<CR>'
  local reject_fmt = '<cmd>lua require("rc.lsp.rename").reject(%d)<CR>'

  vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal")
  vim.api.nvim_buf_set_option(buf, "ft", "LspRenamePrompt")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { cword })

  local keymap_opt = { silent = true, buffer = buf }
  vim.keymap.set("i", "<CR>", string.format(accept_fmt, win), keymap_opt)
  vim.keymap.set("n", "<CR>", string.format(accept_fmt, win), keymap_opt)
  vim.keymap.set("n", "q", string.format(reject_fmt, win), keymap_opt)
end

return {
  accept = accept,
  reject = reject,
  rename = rename,
}
